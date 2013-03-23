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
    
    blueprint = Parser.new.parse(source)
    blueprint.should have(3).requests
    
    blueprint.requests[0].verb.should == 'GET'
    blueprint.requests[0].url.should == '/url'
    blueprint.requests[0].contexts.first.response_code.should == 200
    
    blueprint.requests[1].verb.should == 'POST'
    blueprint.requests[1].url.should == '/other_url'
    blueprint.requests[1].contexts.first.response_code.should == 201
    
    blueprint.requests[2].verb.should == 'PUT'
    blueprint.requests[2].url.should == '/another_url'
    blueprint.requests[2].contexts.first.response_code.should == 401
  end
  
  it "parses requests without contexts" do
    source = 'GET /url'
    
    blueprint = Parser.new.parse(source)
    blueprint.requests.first.should_not have_contexts
  end
  
  it "parses requests with json request body" do
    path = File.expand_path('../fixtures/simple', __FILE__)
    source = File.read(path)
    
    blueprint = Parser.new.parse(source)
    blueprint.requests.first.contexts.first.request_body.should == Oj.dump(email: 'a@b.ru', password: 'secret')
  end
end
