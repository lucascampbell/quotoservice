require 'spec_helper'
describe ApiController do
  
  before(:each) do
    request.env['HTTP_AUTHORIZATION'] = '&3!kZ1Ct:zh7GaM'
    Quote.delete_all
    Tag.delete_all
    Topic.delete_all
  end
  
  it "should return 500 with bad token" do
    request.env['HTTP_AUTHORIZATION'] = 'badtoken'
    get 'get_quotes',:id=>1
    response.status.should == 500
  end
  
  it "should return with 2 correct quotes" do
    Quote.create({:quote => "new test quote1", :citation => "new test citations1", :book => "new test book1", :active=>true})
    Quote.create( {:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
    get 'get_quotes',:id=>0
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp["q"].count.should == 2
    resp["id"].should == 2
  end
  
  it "should return with 1 correct quotes" do
     Quote.create({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
     Quote.create( {:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
     get 'get_quotes',:id=>1
     response.status.should == 200
     resp = JSON.parse(response.body)
     resp["q"].count.should == 1
     resp["id"].should == 2
  end
  
  it "should return with noupdates" do
     Quote.create({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
     Quote.create( {:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
     get 'get_quotes',:id=>2
     response.status.should == 200
     resp = JSON.parse(response.body)
     resp["q"].should == "noupdates"
     resp["id"].should == nil
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
    post "set_quote",{:book => 'testbook', :citation =>'testcitation', :id=>'3002',:id_last => '4000'}
    response.status.should == 400
    resp = JSON.parse(response.body)
    resp['text'].should == "Bad data error"
  end
  
  it "should return new id if id exists" do
    q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
    q.set_id
    q.save
    post "set_quote",{:quote => 'test quote', :book => 'testbook', :citation =>'testcitation', :id=>'5',:id_last => '4000'}
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp['id'].should == 1667
    resp['q'].should == 'noupdates'
    Quote.last.book.should == 'testbook'
  end
  
  it "should return updates if quote found" do
    q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
    q.set_id
    q.save
    q1 = Quote.new({:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
    q1.set_id
    q1.save
    
    post "set_quote",{:quote => 'new test quote2', :book => 'new test book2', :citation =>'new test citations2', :id_last => '1666'}
    resp = JSON.parse(response.body)
    resp['id'].should == 1667
    resp['q'].first['book'].should == 'new test book2'
  end
  
  it "should merge tag ids into get quotes resp" do
    q = Quote.new({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
    q.set_id
    t1 = Tag.create({:name=>'tag1',:id=>1})
    t2 = Tag.create({:name=>'tag2',:id=>2})
    q.tags << t1
    q.tags << t2
    q.save
    get 'get_quotes',:id=>1
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
    get 'get_quotes',:id=>1
    resp = JSON.parse(response.body)
    resp["q"].first["topic_ids"].size.should == 2
  end
end
