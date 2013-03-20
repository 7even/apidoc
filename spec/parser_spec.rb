require 'spec_helper'

describe Parser do
  it "parses basic requests" do
    source = <<-EOF
      GET /url
      < 200
      POST /other_url
      < 201
      PUT /another_url
      < 401
    EOF
    
    result = Parser.new.parse(source)
    result.should have(3).requests
    
    result[0].verb.should == 'GET'
    result[0].url.should == '/url'
    result[0].contexts.first.response_code.should == 200
    
    result[1].verb.should == 'POST'
    result[1].url.should == '/other_url'
    result[1].contexts.first.response_code.should == 201
    
    result[2].verb.should == 'PUT'
    result[2].url.should == '/another_url'
    result[2].contexts.first.response_code.should == 401
  end
end
