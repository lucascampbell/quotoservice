require 'spec_helper'

describe QuotesController do
  context "authentication" do
    before(:each) do
      @user = FactoryGirl.create(:user)
      sign_in @user
    end
    
    after(:each) do
      Quote.delete_all
    end
    
    after (:all) do
      sign_out @user
    end
  
    it "should render index" do
      get 'index'
      assigns(:quotes).should eq(Quote.all)
      response.should render_template('index')
    end
  
    it "should create new quote and redirect" do
      Quote.delete_all
      params = {:quote => {:quote => 'new test quote', :citation => "new test citations", :book => 'new test book'}}
      post 'create',params
      Quote.count.should == 1
      response.should redirect_to('/quotes')
    end
  
    it "should create new quote with tags and redirect" do
      Quote.delete_all
      t1 = Tag.new({:name=>'tag1'})
      t1.set_id
      t1.save
      t2 = Tag.new({:name=>'tag2'})
      t2.set_id
      t2.save
      params = {:quote => {:quote => 'new test quote', :citation => "new test citations", :book => 'new test book',:tags=>["",t1.id,t2.id]}}
      post 'create',params
      Quote.count.should == 1
      q = Quote.first
      q.tags.count.should == 2
      response.should redirect_to('/quotes')
    end
  
    it "should update quote with new value" do
      quote = Quote.create({:quote => 'new test quote', :citation => "new test citations", :book => 'new test book',:translation=>'translation'})
      params = {:quote => {:quote => 'new edit test quote',},:id=>quote.id}
      put 'update',params
      quote = Quote.first.quote.should == 'new edit test quote'
    end
  
    it "should activate quote" do
      quote = Quote.create!({:quote => 'new test quote', :citation => "new test citations", :book => 'new test book',:translation=>'translation'})
      quote.active.should == false
      get "activate",:id=>quote.id
      quote2 = Quote.find(quote.id)
      quote2.active.should == true
      response.should redirect_to('/quotes')
    end
  
    it "should remove all quote creates when quote is deactivated" do
      quote = Quote.create!({:quote => 'new test quote', :citation => "new test citations", :book => 'new test book',:translation=>'translation',:active=>true})
      quote.log_create
      QuoteCreate.count.should == 1
    
      get "deactivate", :id=>quote.id
      QuoteCreate.count.should == 0
      QuoteDelete.count.should == 1
    end
    
    it "should create quotecreate and quotedelete when update occurs" do
      quote = Quote.create!({:quote => 'new test quote', :citation => "new test citations", :book => 'new test book',:translation=>'translation',:active=>true})
      quote.log_create
      QuoteCreate.count.should == 1
      params = {:quote=>{:citation=>quote.citation,:book=>quote.book,:rating=>3},:id=>quote.id}
      put "update", params
      response.should redirect_to('/quotes')
      QuoteCreate.count.should == 2
      QuoteDelete.count.should == 1
    end
  
    it "should remove all quote creates when quote is deactivated but leave other quotes" do
      quote = Quote.create!({:quote => 'new test quote', :citation => "new test citations", :book => 'new test book',:translation=>'translation',:active=>true})
      quote2 = Quote.create!({:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2',:translation=>'translation',:active=>true})
      quote.log_create
      QuoteCreate.count.should == 1
      quote2.log_create
      QuoteCreate.count.should == 2
    
      get "deactivate", :id=>quote.id
      QuoteCreate.count.should == 1
      QuoteDelete.count.should == 1
     
      QuoteCreate.first.quote_id.should == quote2.id
    end
  
    it "should remove all quote creates when quote is destroyed but leave other quotes" do
      quote = Quote.create!({:quote => 'new test quote', :citation => "new test citations", :book => 'new test book',:translation=>'translation',:active=>true})
      quote2 = Quote.create!({:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2',:translation=>'translation',:active=>true})
      quote.log_create
      QuoteCreate.count.should == 1
      quote2.log_create
      QuoteCreate.count.should == 2
    
      get "destroy", :id=>quote.id
      QuoteCreate.count.should == 1
      QuoteDelete.count.should == 1
      QuoteCreate.first.quote_id.should == quote2.id
    end
  end
  context "json request" do
    
    before(:each) do
      request.env['HTTP_AUTHORIZATION'] = '&3!kZ1Ct:zh7GaM'
    end
    
    after (:each) do
      Quote.delete_all
    end
    
    it "should not authenticate if get json request" do
      quote = Quote.create!({:quote => 'new test quote', :citation => "new test citations", :book => 'new test book',:translation=>'translation',:active=>true})
      expected = Quote.all
      get 'index',:page=>1,:callback=>'awesome', :format=>:json
      assigns(:quotes).should eq(expected)
    end
    
    it "should  authenticate if get non json request" do
       quote = Quote.create!({:quote => 'new test quote', :citation => "new test citations", :book => 'new test book',:translation=>'translation',:active=>true})
       expected = Quote.all
       get 'index',:page=>1
       response["Location"].should =~ /sign_in/
     end
    
    it "should fail to post json request" do
      post "create",{:quote=>'test'}
      response["Location"].should =~ /sign_in/
    end
  end
    
end