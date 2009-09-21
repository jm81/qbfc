require 'spec_helper'

describe QBFC::Terms do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
  end

  it "is a base class" do
    QBFC::Terms.is_base_class?.should be_true
  end
  
  describe ".find" do
    it "should return subclass objects"
  end
  
end