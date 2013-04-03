require 'spec_helper'

describe IncomingRequest do
  before(:each) do
    @rack_request = stub("Rack::Request instance")
    @incoming_request = IncomingRequest.new(@rack_request)
  end
  
  describe "#has_query_string?" do
    context "with an empty query_string" do
      before(:each) do
        @rack_request.stub(:GET).and_return({})
      end
      
      it "returns false" do
        @incoming_request.should_not have_query_string
      end
    end
    
    context "with a non-empty query_string" do
      before(:each) do
        @rack_request.stub(:GET).and_return(a: 1)
      end
      
      it "returns true" do
        @incoming_request.should have_query_string
      end
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
end
