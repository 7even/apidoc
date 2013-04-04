require 'spec_helper'

describe Formatter do
  describe ".format_query" do
    before(:each) do
      @query_params = {
        'first_name' => 'John',
        'last_name'  => 'Smith'
      }
    end
    
    it "returns a query string built from the params hash" do
      Formatter.format_query(@query_params).should == 'first_name=John&last_name=Smith'
    end
  end
  
  describe ".format_body" do
    before(:each) do
      @body_params = {
        'id'    => '#{id}',
        'email' => 'user@example.com'
      }
    end
    
    it "returns prettified json with properly formatted variables" do
      expected = <<-EOL
{
  "id": id,
  "email": "user@example.com"
}
      EOL
      
      Formatter.format_body(@body_params).should == expected.strip
    end
  end
end
