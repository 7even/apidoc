require 'spec_helper'

describe Blueprint do
  describe ".parse" do
    before(:each) do
      specification_path = File.expand_path('../../fixtures/simple', __FILE__)
      @specification = File.read(specification_path)
    end
    
    it "parses the specification with Parser and saves the result" do
      blueprint = stub("Blueprint built by parser")
      Parser.any_instance.should_receive(:parse).with(@specification).and_return(blueprint)
      blueprint.should_receive(:save)
      
      Blueprint.parse(@specification).should == blueprint
    end
  end
end
