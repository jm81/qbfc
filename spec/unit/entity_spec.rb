require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QBFC::Entity do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
  end

  it "is a base class" do
    QBFC::Entity.is_base_class?.should be_true
  end
  
  describe ".find" do
    it "should return subclass objects"
  end
  
end