require 'spec_helper'
describe ApiController do
  
  before(:each) do
    request.env['HTTP_AUTHORIZATION'] = '&3!kZ1Ct:zh7GaM'
    Quote.delete_all
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
  
  it "should return with uptodate" do
     Quote.create({:quote => 'new test quote1', :citation => "new test citations1", :book => 'new test book1', :active=>true})
     Quote.create( {:quote => 'new test quote2', :citation => "new test citations2", :book => 'new test book2', :active=>true})
     get 'get_quotes',:id=>2
     response.status.should == 200
     resp = JSON.parse(response.body)
     resp["q"].count.should == 0
     resp["id"].should == 'uptodate'
  end
   
  it "should set new quote and return original id" do
     post "set_quote",{:quote => 'test quote', :book => 'testbook', :citation =>'testcitation', :id=>'3002',:id_last => '4000'}
     response.status.should == 200
     resp = JSON.parse(response.body)
     resp['id'].should == 3002
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
    post "set_quote",{:quote => 'test quote', :book => 'testbook', :citation =>'testcitation', :id=>'3000',:id_last => '4000'}
    response.status.should == 200
    resp = JSON.parse(response.body)
    resp['id'].should == 3001
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
    
    post "set_quote",{:quote => 'new test quote2', :book => 'new test book2', :citation =>'new test citations2', :id=>'3003',:id_last => '3000'}
    resp = JSON.parse(response.body)
    resp['id'].should == 3001
    resp['q'].first['book'].should == 'new test book2'
  end
end
