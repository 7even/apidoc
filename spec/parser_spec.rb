require 'spec_helper'

describe Parser do
  before(:each) do
    @parser = Parser.new
  end
  
  it "parses basic requests" do
    source = <<-EOF
      GET /url
      < 200
      POST /other_url
      < 201
      PUT /another_url
      < 401
    EOF
    
    blueprint = @parser.parse(source)
    blueprint.should_not be_nil
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
    
    blueprint = @parser.parse(source)
    blueprint.should_not be_nil
    blueprint.requests.first.should_not have_contexts
  end
  
  it "parses requests with json request body" do
    path = File.expand_path('../fixtures/simple', __FILE__)
    source = File.read(path)
    
    blueprint = @parser.parse(source)
    blueprint.should_not be_nil
    blueprint.should have(4).requests
    blueprint.requests.first.contexts.first.request_body.should == Oj.dump(email: 'a@b.ru', password: 'secret')
  end
  
  it "parses contexts with variables in response_body" do
    path = File.expand_path('../fixtures/simple', __FILE__)
    source = File.read(path)
    
    blueprint = @parser.parse(source)
    Oj.load(blueprint.requests.last.contexts.first.response_body)['id'].should == '#{id}'
  end
  
  it "parses contexts with multiple headers" do
    source = <<-EOF
      GET /users
      > X-First-Header: abc
      > X-Second-Header: def
      < X-Third-Header: ghi
      < X-Fourth-Header: jkl
      < X-Fifth-Header: mno
    EOF
    
    blueprint = @parser.parse(source)
    blueprint.should_not be_nil
    blueprint.requests.first.contexts.first.request_headers.count.should == 2
    blueprint.requests.first.contexts.first.response_headers.count.should == 3
  end
  
  it "parses requests with multiple contexts" do
    path = File.expand_path('../fixtures/contexts', __FILE__)
    source = File.read(path)
    
    blueprint = @parser.parse(source)
    blueprint.should_not be_nil
    blueprint.requests.first.should have(2).contexts
  end
end
