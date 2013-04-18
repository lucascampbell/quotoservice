require 'spec_helper'
describe ApiController do
  
  before(:each) do
    request.env['HTTP_AUTHORIZATION'] = '&3!kZ1Ct:zh7GaM'
    Quote.delete_all
    Tag.delete_all
    Topic.delete_all
    QuoteCreate.delete_all
    QuoteDelete.delete_all
    TopicCreate.delete_all
    TopicDelete.delete_all
    TagCreate.delete_all
    TagDelete.destroy_all
    Image.destroy_all
    ImageCreate.destroy_all
    ImageDelete.destroy_all
    ActiveRecord::Base.connection.reset_pk_sequence!('quotes')
    ActiveRecord::Base.connection.reset_pk_sequence!('quote_creates')
    ActiveRecord::Base.connection.reset_pk_sequence!('quote_deletes')
    ActiveRecord::Base.connection.reset_pk_sequence!('topic_creates')
    ActiveRecord::Base.connection.reset_pk_sequence!('topic_deletes')
    ActiveRecord::Base.connection.reset_pk_sequence!('tag_creates')
    ActiveRecord::Base.connection.reset_pk_sequence!('tag_deletes')
    ActiveRecord::Base.connection.reset_pk_sequence!('image_creates')
    ActiveRecord::Base.connection.reset_pk_sequence!('image_deletes')
  end
  
  it "should return 500 with bad token" do
    request.env['HTTP_AUTHORIZATION'] = 'badtoken'
    get 'get_quotes',{:id=>1,:delete_id=>0,:update_id=>0}
    response.status.should == 500
  end
  
  it "should return with 2 correct quotes" do
    q = Quote.create!({:quote => "new test quote1", :citation => "new test citations1", :book => "new test book1", :active=>true})
    q.log_create
    q1 = Quote.create!( {:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
    q1.log_create
    get 'get_quotes',{:id=>0,:delete_id=>0,:update_id=>0}
    response.status.should == 200
    resp = JSON.parse(response.body)
    puts resp
    resp["q"].count.should == 2
  end
  
  it "should return with 1 correct quotes" do
     q = Quote.create({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
     q.log_create
     q1 = Quote.create( {:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
     q1.log_create
     get 'get_quotes',{:id=>1,:delete_id=>0,:update_id=>0}
     response.status.should == 200
     resp = JSON.parse(response.body)
     puts resp
     resp["q"].count.should == 1
  end
  
  it "should return with noupdates" do
     Quote.create({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
     Quote.create( {:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
     get 'get_quotes',{:id=>2,:delete_id=>0,:update_id=>0}
     response.status.should == 200
     resp = JSON.parse(response.body)
     resp["q"].should == "noupdates"
     resp["id"].should == nil
  end
  
  it "should only return quotes that are not updated" do
    q = Quote.create!({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
    q.log_create
    
    get 'get_quotes',{:id=>0,:delete_id=>0,:update_id=>0}
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp["q"].count.should == 1
    resp["id"].should == 1
    resp['update'].should == nil
    
    q.citation = 'test citation'
    q.save!
    
    get 'get_quotes',{:id=>0,:delete_id=>0,:update_id=>0}
    response.status.should == 200
    resp = JSON.parse(response.body)
    
    resp["q"].count.should == 1
    resp["id"].should == 1
    resp["update"].first['quote_id'].should == 1
  end
   
  it "should set new quote and return original id" do
     post "set_quote",{:quote => 'test quote', :book => 'testbook', :citation =>'testcitation', :id=>'5',:id_last => '4000'}
     response.status.should == 200
     resp = JSON.parse(response.body)
     resp['id'].should == 1666
     resp['q'].should == 'noupdates'
     Quote.first.book.should == 'testbook'
  end
  
  it "should return bad data error if missing field" do
    post "set_quote",{:book => 'testbook', :citation =>'testcitation', :id=>'3002'}
    response.status.should == 400
    resp = JSON.parse(response.body)
    resp['text'].should == "Bad data error"
  end
  
  it "should return new id if id exists" do
    q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
    q.set_id
    q.save
    post "set_quote",{:quote => 'test quote', :book => 'testbook', :citation =>'testcitation', :id=>'5'}
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp['id'].should == 1667
    resp['q'].should == 'noupdates'
    Quote.last.book.should == 'testbook'
  end
  
  it "should merge tag ids into get quotes resp" do
    q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
    q.set_id
    t1 = Tag.create({:name=>'tag1',:id=>1})
    t2 = Tag.create({:name=>'tag2',:id=>2})
    q.tags << t1
    q.tags << t2
    q.save
    q.log_create
    get 'get_quotes',{:id=>0,:delete_id=>0,:update_id=>0}
    resp = JSON.parse(response.body)
    resp["q"].first["tag_ids"].size.should == 2
  end
  
  it "should merge tag ids into get quotes resp" do
    q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
    q.set_id
    t1 = Topic.create({:name=>'topic1',:id=>1})
    t2 = Topic.create({:name=>'topic2',:id=>2})
    q.topics << t1
    q.topics << t2
    q.save
    q.log_create
    get 'get_quotes',{:id=>0,:delete_id=>3,:update_id=>0}
    resp = JSON.parse(response.body)
    puts resp
    resp["q"].first["topic_ids"].size.should == 2
  end
  
  it "should return success even if app and token exist" do
     APN::App.delete_all
     token = '5gxadhy6 6zmtxfl6 5zpbcxmw ez3w7ksf qscpr55t trknkzap 7yyt45sc g6jrw7qz'
     app = APN::App.create!(:apn_dev_cert => "apple_push_development.pem", :apn_prod_cert => "")
     a = APN::Device.create(:token => token,:app_id => app.id)
     APN::Group.create(:app_id => app.id,:name=>"APPLE")
     get 'register_device', {:id => token,:platform=>'APPLE'}
     resp = JSON.parse(response.body)
     resp["text"].should == 'success'
  end
  
  it "should return not found if no id passed" do
     APN::App.delete_all
     get 'register_device'
     resp = JSON.parse(response.body)
     resp['text'].should == 'Not Found.'
  end
  
  it "should return register device if new" do
      APN::App.delete_all
      APN::Device.delete_all
      token = '5gxadhy6 6zmtxfl6 5zpbcxmw ez3w7ksf qscpr55t trknkzap 7yyt45sc g6jrw7qz'
      app = APN::App.create!(:apn_dev_cert => "apple_push_development.pem", :apn_prod_cert => "")
      APN::Group.create(:app_id => app.id,:name=>"APPLE")
      get 'register_device', {:id => token,:platform=>'APPLE'}
      resp = JSON.parse(response.body)
      resp["text"].should == 'success'
      APN::Device.count.should == 1
      APN::App.count.should == 1
   end
   
   it "should return register device if new" do
       APN::App.delete_all
       APN::Device.delete_all
       token = '5gxadhy6 6zmtxfl6 5zpbcxmw ez3w7ksf qscpr55t trknkzap 7yyt45sc g6jrw7qz'
       app = APN::App.create!(:apn_dev_cert => "apple_push_development.pem", :apn_prod_cert => "")
       APN::Group.create(:app_id => app.id,:name=>"APPLE")
       #a = APN::Device.create(:token => token,:app_id => app.id)
       get 'register_device', {:id => token,:platform=>'APPLE'}
       resp = JSON.parse(response.body)
       resp["text"].should == 'success'
       APN::Device.count.should == 1
       APN::App.count.should == 1
    end
    
    it "should return success if error is that it already exists for apple" do
       APN::App.delete_all
       APN::Device.delete_all
       APN::Group.delete_all
       app = APN::App.create!(:apn_dev_cert => "apple_push_development.pem", :apn_prod_cert => "")
       g = APN::Group.create!({:name=>'APPLE',:app_id => app.id})
   
       token = '5gxadhy6 6zmtxfl6 5zpbcxmw ez3w7ksf qscpr55t trknkzap 7yyt45sc g6jrw7qz'
       #a = APN::Device.create(:token => token,:app_id => app.id)
       get 'register_device', {:id => token,:platform=>'APPLE'}
       resp = JSON.parse(response.body)
       resp["text"].should == 'success'
       APN::Device.count.should == 1
       APN::App.count.should == 1
       
       get 'register_device', {:id => token,:platform=>'APPLE'}
       resp = JSON.parse(response.body)
       resp["text"].should == 'success'
       APN::Device.count.should == 1
       APN::App.count.should == 1
    end
    
    it "should add device to android group" do
      APN::App.delete_all
      APN::Device.delete_all
      C2dm::Device.delete_all
      
      token = '5gxadhy6 6zmtxfl6 5zpbcxmw ez3w7ksf qscpr55t trknkzap 7yyt45sc g6jrw7qz'
      app = APN::App.create!(:apn_dev_cert => "apple_push_development.pem", :apn_prod_cert => "")
      APN::Group.create(:app_id => app.id,:name=>"ANDROID")
      get 'register_device', {:id => token,:platform=>'ANDROID'}
      resp = JSON.parse(response.body)
      resp["text"].should == 'success'
      C2dm::Device.count.should == 1
      gr = APN::Group.find(:first)
      gr.c2_devices.count.should == 1
    end
    
    it "should return success if error is that it already exists for android" do
      APN::App.delete_all
      APN::Device.delete_all
      C2dm::Device.delete_all
      
      token = '5gxadhy6 6zmtxfl6 5zpbcxmw ez3w7ksf qscpr55t trknkzap 7yyt45sc g6jrw7qz'
      app = APN::App.create!(:apn_dev_cert => "apple_push_development.pem", :apn_prod_cert => "")
      APN::Group.create(:app_id => app.id,:name=>"ANDROID")
      get 'register_device', {:id => token,:platform=>'ANDROID'}
      resp = JSON.parse(response.body)
      resp["text"].should == 'success'
      C2dm::Device.count.should == 1
      gr = APN::Group.find(:first)
      gr.c2_devices.count.should == 1
      
      get 'register_device', {:id => token,:platform=>'ANDROID'}
      resp = JSON.parse(response.body)
      resp["text"].should == 'success'
      C2dm::Device.count.should == 1
      gr = APN::Group.find(:first)
      gr.c2_devices.count.should == 1
    end
      
    it "should return updates for deleted quotes" do
      q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
      q.set_id
      q.save
      q_id = q.id.to_s
      q1 = Quote.new({:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
      q1.set_id
      q1.save
      q1_id = q1.id.to_s
      q.destroy

      get 'get_quotes',{:id=>1,:delete_id=>0,:update_id=>0}
      resp = JSON.parse(response.body)
      resp["delete"]["ids"].should == q_id.to_s
      
      get 'get_quotes',{:id=>1,:delete_id=>1,:update_id=>0}
      resp = JSON.parse(response.body)
      resp["delete"].should == nil
      
      q1.destroy
      ids_ar = [q_id,q1_id].join(',')
      get 'get_quotes',{:id=>1,:delete_id=>0,:update_id=>0}
      resp = JSON.parse(response.body)
      puts resp
      resp["delete"]["ids"].should == ids_ar
      resp["delete"]["last_id"].should == "2"
    end
    
    
    #V2 tests for get updates
    
    it "should return new creates for created quotes" do
      q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
      q.set_id
      q.save
      q.log_create
      q_id = q.id.to_s
      q1 = Quote.new({:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
      q1.set_id
      q1.save
      q1.log_create
      q1_id = q1.id.to_s
      
      get 'get_updates',{:q_create_id=>0,:q_delete_id=>0,:topic_create_id=>0,:topic_delete_id=>0,:tag_create_id=>0,:tag_delete_id=>0}
      resp = JSON.parse(response.body)
      puts resp
      resp['quotes']['quote_delete'].should == 'noupdates'
     
      resp['quotes']['quote_create'].first['id'].should == q_id.to_i
      resp['quotes']['quote_create'].last['id'].should == q1_id.to_i
    end
    
    it "should return new topics for created quotes" do
      t = Topic.new({:name=>'tst_topic'})
      t.set_id
      t.save
      
      get 'get_updates',{:q_create_id=>0,:q_delete_id=>0,:topic_create_id=>0,:topic_delete_id=>0,:tag_create_id=>0,:tag_delete_id=>0}
      resp = JSON.parse(response.body)
      
      resp['topics']['topic_create'].first['id'].should == t.id
      resp['topics']['topic_create'].first['name'].should == t.name
    end
    
    it "should return new tags for created quotes" do
      t = Tag.new({:name=>'tst_tag',})
      t.set_id
      t.save
      
      get 'get_updates',{:q_create_id=>0,:q_delete_id=>0,:topic_create_id=>0,:topic_delete_id=>0,:tag_create_id=>0,:tag_delete_id=>0}
      resp = JSON.parse(response.body)
      resp['tags']['tag_create'].first['id'].should == t.id
      resp['tags']['tag_create'].first['name'].should == t.name
    end
    
    it "should return delete and create for updated quote" do
       q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
       q.set_id
       q.save
       q.log_create
       q_id = q.id.to_s
       q.update_attributes(:quote=>'new update test quote1')
       
       get 'get_updates',{:q_create_id=>0,:q_delete_id=>0,:topic_create_id=>0,:topic_delete_id=>0,:tag_create_id=>0,:tag_delete_id=>0}
       resp = JSON.parse(response.body)
       #puts resp
       resp['quotes']['quote_delete']['ids'].should == [q_id.to_i]
       resp['quotes']['quote_create'].first['id'].should == q_id.to_i
     end
     
   it "should return delete and create topics for updated quotes" do
      t = Topic.new({:name=>'tst_topic',})
      t.set_id
      t.save
      t.update_attributes(:name=>'test_topic_up')
      get 'get_updates',{:q_create_id=>0,:q_delete_id=>0,:topic_create_id=>1,:topic_delete_id=>0,:tag_create_id=>0,:tag_delete_id=>0}
      resp = JSON.parse(response.body)
      #puts resp
      resp['topics']['topic_create'].first['id'].should == t.id
      #resp['topics']['topic_delete']['ids'].should == t.id.to_s
    end

    it "should return delete create tags for updated quotes" do
      t = Tag.new({:name=>'tst_tag',})
      t.set_id
      t.save
      t.update_attributes(:name=>'test_tag_up')
      
      get 'get_updates',{:q_create_id=>0,:q_delete_id=>0,:topic_create_id=>0,:topic_delete_id=>0,:tag_create_id=>1,:tag_delete_id=>0}
      resp = JSON.parse(response.body)
      resp['tags']['tag_create'].first['id'].should == t.id
      resp['tags']['tag_delete']['ids'].should == [t.id]
    end
    
    it "should return entire snapshot of quotes tags topics" do
      get 'snapshot'
      resp = JSON.parse(response.body)
      puts resp 
    end
    
    it "should return first page of quotes" do
      q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
      q.set_id
      q.save
      q2 = Quote.new({:quote => 'new test quote2', :citation => "new test citations1", :book => 'new test book1', :active=>true})
      q2.set_id
      q2.save
      q3 = Quote.new({:quote => 'new test quote3', :citation => "new test citations1", :book => 'new test book1', :active=>true})
      q3.set_id
      q3.save
      Quote.per_page = 2
      get "quotes_by_page"
      resp = JSON.parse(response.body)
      resp.count.should == 2
      
      get "quotes_by_page",:page =>2
      resp = JSON.parse(response.body)
      resp.count.should == 1
      
      get "quotes_by_page",:page =>3
      resp = JSON.parse(response.body)
      resp.count.should == 0
    end
    
    it "should return first page of topics" do
      t = Topic.new({:name=>'tst_topic'})
      t.set_id
      t.save
      t1 = Topic.new({:name=>'tst_topic2'})
      t1.set_id
      t1.save
      Topic.per_page = 1
      
      get "topics_by_page"
      resp = JSON.parse(response.body)
      resp.count.should == 1
      
      get "topics_by_page",:page => 2
      resp = JSON.parse(response.body)
      resp.count.should == 1
      
      get "topics_by_page",:page => 3
      resp = JSON.parse(response.body)
      resp.count.should == 0
    end
    
    it "should return topics by status" do
      t = Topic.new({:name=>'tst_topic',:status=>'featured'})
      t.set_id
      t.save
      t1 = Topic.new({:name=>'tst_topic2',:status=>'standard'})
      t1.set_id
      t1.save
      Topic.per_page = 1
      
      get "topics_by_status",:id=>'featured'
      resp = JSON.parse(response.body)
      resp.count.should == 1
      resp[0]["status"].should == 'featured'
      
      get "topics_by_status",:id=>'standard'
      resp = JSON.parse(response.body)
      resp.count.should == 1
      resp[0]["status"].should == 'standard'
    end
    
    it "should return qoutes by topic id or name" do
      t = Topic.new({:name=>'tst_topic',:status=>'featured'})
      t.set_id
      t.save
      
      q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
      q.set_id
      q.save
      q2 = Quote.new({:quote => 'new test quote2', :citation => "new test citations1", :book => 'new test book1', :active=>true})
      q2.set_id
      q2.save
      q3 = Quote.new({:quote => 'new test quote3', :citation => "new test citations1", :book => 'new test book1', :active=>true})
      q3.set_id
      q3.save
      
      t.quotes << q
      t.quotes << q2
      
      t.save
      
      get "quotes_by_topic_id_name",:id=>t.id
      resp = JSON.parse(response.body)
      resp.count.should == 2
      
      get "quotes_by_topic_id_name",:name=>t.name
      resp = JSON.parse(response.body)
      resp.count.should == 2
    end
    
    
    it "should return topics by name or id" do
      t = Topic.new({:name=>'tst_topic',:status=>'featured'})
      t.set_id
      t.save!
      
      get "topic_by_id_name",:id=>t.id
      resp = JSON.parse(response.body)
      resp.count.should == 1
      
      get "topic_by_id_name",:name=>t.name
      resp = JSON.parse(response.body)
      resp.count.should == 1
    end
    
    it "should return quotes by search term" do
       q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
       q.set_id
       q.save

       get "quotes_by_search",:search=>"new"
       resp = JSON.parse(response.body)
       resp.count.should == 1
       resp[0]["id"].should == q.id
       
       get "quotes_by_search",:search=>"whatzup"
       resp = JSON.parse(response.body)
       resp.count.should == 0
    end
    
    it "should return quote by id" do
      q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
      q.set_id
      q.save
      
      get "quote_by_id",:id=>q.id
      resp = JSON.parse(response.body)
      resp.count.should == 1
      resp[0]["id"].should == q.id
    end
    
    it "should create image record" do
      Image.all.count.should == 0
      post "create_image",{:name=>'test',:device_name=>'test'}
      resp = JSON.parse(response.body)
      resp['text'].should == 'success'
      Image.first.device_name.should == 'test'
    end
    
    it "should fail to create image record" do
       Image.all.count.should == 0
       post "create_image",{:name=>'test'}
       resp = JSON.parse(response.body)
       resp['text'].should == 'Bad data error'
       Image.all.count.should == 0
    end
    
    it "should return image updates on create" do
      i = Image.create!(:name=>'test')
      get "get_image_updates",{:i_create_id=>0,:i_delete_id=>0}
      
      resp = JSON.parse(response.body)
      resp['images']['image_create'].first['id'].should == i.id
      resp['images']['image_delete']['ids'].should == nil
    end
    
    it "should return image updates on delete" do
      Image.any_instance.stub(:remove_from_s3).and_return(true)
      i = Image.create!(:name=>'test')
      i.destroy
      get "get_image_updates",{:i_create_id=>0,:i_delete_id=>0}
      
      resp = JSON.parse(response.body)
      resp['images']['image_create'].should == "noupdates"
      resp['images']['image_delete']['ids'].should == [i.id]
    end
    
    it "should return image updates on delete" do
      Image.any_instance.stub(:remove_from_s3).and_return(true)
      i = Image.create!(:name=>'test')
      i.update_attributes(:email=>'updateuseremail')
      get "get_image_updates",{:i_create_id=>0,:i_delete_id=>0}
      
      resp = JSON.parse(response.body)
      
      resp['images']['image_create'].first["id"].should == i.id
      resp['images']['image_delete']['ids'].should == [i.id]
    end
      
end
