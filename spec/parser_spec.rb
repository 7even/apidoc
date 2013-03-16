require 'spec_helper'

describe Parser do
  it "parses basic requests" do
    result = Parser.new.parse("GET /url\nPOST /other_url\nPUT /another_url")
    result.should have(3).requests
    
    result[0].verb.should == 'GET'
    result[0].url.should == '/url'
    
    result[1].verb.should == 'POST'
    result[1].url.should == '/other_url'
    
    result[2].verb.should == 'PUT'
    result[2].url.should == '/another_url'
  end
end
