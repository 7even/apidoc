require 'spec_helper'

describe IncomingRequest do
  before(:each) do
    @rack_request = stub("Rack::Request instance")
    @incoming_request = IncomingRequest.new(@rack_request)
  end
  
  describe "#verb_matches?" do
    before(:each) do
      @verb = 'GET'
    end
    
    context "with a matching verb" do
      before(:each) do
        @rack_request.stub(:request_method).and_return('GET')
      end
      
      it "returns true" do
        @incoming_request.verb_matches?(@verb).should be_true
      end
    end
    
    context "with another verb" do
      before(:each) do
        @rack_request.stub(:request_method).and_return('POST')
      end
      
      it "returns false" do
        @incoming_request.verb_matches?(@verb).should be_false
      end
    end
  end
  
  describe "#url_matches?" do
    context "with a common url" do
      before(:each) do
        @url = '/users'
      end
      
      context "matching the specification" do
        before(:each) do
          @rack_request.stub(:path_info).and_return('/users')
        end
        
        it "returns true" do
          @incoming_request.url_matches?(@url).should be_true
        end
      end
      
      context "missing the specification" do
        before(:each) do
          @rack_request.stub(:path_info).and_return('/posts')
        end
        
        it "returns false" do
          @incoming_request.url_matches?(@url).should be_false
        end
      end
    end
    
    context "with a url containing variables" do
      before(:each) do
        @url = '/users/:id'
      end
      
      context "matching the specification" do
        before(:each) do
          @rack_request.stub(:path_info).and_return('/users/1')
        end
        
        it "returns true" do
          @incoming_request.url_matches?(@url).should be_true
        end
      end
      
      context "missing the specification" do
        before(:each) do
          @rack_request.stub(:path_info).and_return('/posts/:id')
        end
        
        it "returns false" do
          @incoming_request.url_matches?(@url).should be_false
        end
      end
    end
  end
  
  describe "#url_params" do
    before(:each) do
      @url = '/users/:id'
      @rack_request.stub(:path_info).and_return('/users/1')
    end
    
    it "returns a hash with url variables" do
      @incoming_request.url_params(@url).should == { 'id' => '1' }
    end
  end
  
  describe ".pattern_from_url" do
    it "replaces variables with named groups" do
      IncomingRequest.pattern_from_url('/users/:id').should == '\A/users/(?<id>[A-Za-z0-9_]+)\Z'
    end
  end
  
  describe "#query_string_matches?" do
    before(:each) do
      @params = { x: 1 } # params from specification
    end
    
    context "with keys matching to query params" do
      before(:each) do
        @rack_request.stub(:GET).and_return('x' => 1, 'y' => 2)
      end
      
      it "returns true" do
        @incoming_request.query_string_matches?(@params).should be_true
      end
    end
    
    context "with some keys missing" do
      before(:each) do
        @rack_request.stub(:GET).and_return('y' => 2, 'z' => 3)
      end
      
      it "returns false" do
        @incoming_request.query_string_matches?(@params).should be_false
      end
    end
  end
  
  describe "#headers_match?" do
    before(:each) do
      @headers = { 'X-First-Header' => 'value' }
    end
    
    context "with keys matching to header names" do
      before(:each) do
        @rack_request.stub(:env).and_return(
          'HTTP_X_FIRST_HEADER'  => 'first_value',
          'HTTP_X_SECOND_HEADER' => 'second_value'
        )
      end
      
      it "returns true" do
        @incoming_request.headers_match?(@headers).should be_true
      end
    end
    
    context "with some keys missing" do
      before(:each) do
        @rack_request.stub(:env).and_return(
          'HTTP_X_SECOND_HEADER' => 'second_value',
          'HTTP_X_THIRD_HEADER'  => 'third_value'
        )
      end
      
      it "returns false" do
        @incoming_request.headers_match?(@headers).should be_false
      end
    end
  end
  
  describe "#body_matches?" do
    before(:each) do
      @body_params = {
        first_name: 'John',
        last_name:  'Smith'
      }
    end
    
    context "with form-data" do
      before(:each) do
        @rack_request.stub(:form_data?).and_return(true)
      end
      
      context "and keys matching to body params" do
        before(:each) do
          body_string = 'first_name=Henry&last_name=Colby'
          @rack_request.stub_chain(:body, :read).and_return(body_string)
        end
        
        it "returns true" do
          @incoming_request.body_matches?(@body_params).should be_true
        end
      end
      
      context "and some keys missing" do
        before(:each) do
          body_string = 'first_name=John&patronymic=Malkovich'
          @rack_request.stub_chain(:body, :read).and_return(body_string)
        end
        
        it "returns false" do
          @incoming_request.body_matches?(@body_params).should be_false
        end
      end
    end
    
    context "with application/json" do
      before(:each) do
        @rack_request.stub(:form_data?).and_return(false)
      end
      
      context "and keys matching to body params" do
        before(:each) do
          body_string = Oj.dump(first_name: 'Henry', last_name: 'Colby')
          @rack_request.stub_chain(:body, :read).and_return(body_string)
        end
        
        it "returns true" do
          @incoming_request.body_matches?(@body_params).should be_true
        end
      end
      
      context "and some keys missing" do
        before(:each) do
          body_string = Oj.dump(first_name: 'John', patronymic: 'Malkovich')
          @rack_request.stub_chain(:body, :read).and_return(body_string)
        end
        
        it "returns false" do
          @incoming_request.body_matches?(@body_params).should be_false
        end
      end
    end
  end
end
