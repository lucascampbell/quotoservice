require 'spec_helper'

describe QuotesController do
  before (:each) do
    @user = FactoryGirl.create(:user)
    sign_in @user
  end
    
  after (:each) do
    Quote.delete_all
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
end