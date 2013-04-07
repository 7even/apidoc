require 'spec_helper'

describe Request do
  before(:each) do
    @request = Request.new do |r|
      r.verb = 'GET'
      r.url  = '/users'
    end
    
    @incoming_request = stub("Incoming request")
  end
  
  describe "#matches?" do
    context "with a matching request" do
      it "returns true" do
        @incoming_request.should_receive(:verb_matches?).with(@request.verb).and_return(true)
        @incoming_request.should_receive(:url_matches?).with(@request.url).and_return(true)
        
        @request.matches?(@incoming_request).should be_true
      end
    end
    
    context "with a different request" do
      it "returns false" do
        @incoming_request.should_receive(:verb_matches?).with(@request.verb).and_return(false)
        
        @request.matches?(@incoming_request).should be_false
      end
    end
  end
end
