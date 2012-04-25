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
  
  it "should update quote with new value" do
    quote = Quote.create({:quote => 'new test quote', :citation => "new test citations", :book => 'new test book'})
    params = {:quote => {:quote => 'new edit test quote',},:id=>quote.id}
    put 'update',params
    quote = Quote.first.quote.should == 'new edit test quote'
  end
  
  it "should activate quote" do
    quote = Quote.create({:quote => 'new test quote', :citation => "new test citations", :book => 'new test book'})
    quote.active.should == false
    get "activate",:id=>quote.id
    quote = Quote.first
    quote.active.should == true
    response.should redirect_to('/quotes')
  end
end