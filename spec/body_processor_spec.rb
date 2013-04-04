require 'spec_helper'

describe BodyProcessor do
  describe ".process_for_rendering" do
    before(:each) do
      @body = {
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
      
      BodyProcessor.process_for_rendering(@body).should == expected.strip
    end
  end
end
