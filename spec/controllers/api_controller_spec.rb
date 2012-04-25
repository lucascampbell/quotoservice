require 'spec_helper'
describe ApiController do
  
  before(:each) do
    request.env['HTTP_AUTHORIZATION'] = '&3!kZ1Ct:zh7GaM'
  end
  
  it "should return 500 with bad token" do
    request.env['HTTP_AUTHORIZATION'] = 'badtoken'
    get 'get_quotes',:id=>1
    response.status.should == 500
  end
  
  it "should return with 2 correct quotes" do
    Quote.delete_all
    Quote.create({:quote => "new test quote1", :citation => "new test citations1", :book => "new test book1", :active=>true})
    Quote.create( {:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
    get 'get_quotes',:id=>0
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp["q"].count.should == 2
    resp["id"].should == 2
  end
  
  it "should return with 1 correct quotes" do
     Quote.delete_all
     Quote.create({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
     Quote.create( {:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
     get 'get_quotes',:id=>1
     response.status.should == 200
     resp = JSON.parse(response.body)
     resp["q"].count.should == 1
     resp["id"].should == 2
  end
  
  it "should return with uptodate" do
     Quote.delete_all
     Quote.create({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
     Quote.create( {:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
     get 'get_quotes',:id=>2
     response.status.should == 200
     resp = JSON.parse(response.body)
     resp["q"].count.should == 0
     resp["id"].should == 'uptodate'
   end
end
