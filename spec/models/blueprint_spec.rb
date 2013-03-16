require 'spec_helper'

describe Blueprint do
  describe ".parse" do
    before(:each) do
      specification_path = File.expand_path('../../fixtures/simple', __FILE__)
      @specification = File.read(specification_path)
    end
    
    it "creates a new Blueprint from a string" do
      pending
      blueprint = Blueprint.parse(@specification)
      blueprint.should be_a(Blueprint)
    end
  end
end
