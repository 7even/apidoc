require 'spec_helper'

describe Blueprint do
  describe ".parse" do
    before(:each) do
      specification_path = File.expand_path('../../fixtures/simple', __FILE__)
      @specification = File.read(specification_path)
      
      @blueprint = Blueprint.new
      Parser.any_instance.stub(:parse).and_return(@blueprint)
    end
    
    it "parses the specification with Parser" do
      Parser.any_instance.should_receive(:parse).with(@specification)
      Blueprint.parse(@specification).should == @blueprint
    end
    
    it "saves the specification text in .specification" do
      Blueprint.parse(@specification)
      @blueprint.specification.should == @specification
    end
    
    it "persists the record" do
      Blueprint.parse(@specification)
      @blueprint.should be_persisted
    end
  end
end
