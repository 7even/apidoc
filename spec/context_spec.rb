require 'spec_helper'

describe Context do
  before(:each) do
    @context = Context.new do |c|
      c.request_query_params = { a: 1, b: 2 }
      c.request_headers = {
        'X-First-Header'  => 'first_value',
        'X-Second-Header' => 'second_value'
      }
      c.request_body_params = { c: 3, d: 4 }
      
      c.response_code = 200
      c.response_headers = {
        'X-Third-Header'  => 'third_value',
        'X-Fourth-Header' => 'fourth_value'
      }
      c.response_body_params = { e: 5, f: 6 }
    end
    
    @incoming_request = stub("Incoming request")
  end
  
  describe "#matches?" do
    context "with a matching request" do
      it "returns true" do
        @incoming_request.should_receive(:query_string_matches?).with(@context.request_query_params).and_return(true)
        @incoming_request.should_receive(:headers_match?).with(@context.request_headers).and_return(true)
        @incoming_request.should_receive(:body_matches?).with(@context.request_body_params).and_return(true)
        
        @context.matches?(@incoming_request).should be_true
      end
    end
    
    context "with a different request" do
      it "returns false" do
        @incoming_request.should_receive(:query_string_matches?).with(@context.request_query_params).and_return(false)
        @context.matches?(@incoming_request).should be_false
      end
    end
  end
end