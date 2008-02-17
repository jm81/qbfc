require File.dirname(__FILE__) + '/../spec_helper'

# An Element is a Transaction or a List; that is any QuickBooks objects that can
# be created, edited (possibly), deleted and read. Contrast to a Report or Info
# which are read-only.
# 
# 
describe QBFC::Element do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    @ole_methods = ["FullName", "DataExtRetList"]
    @element = QBFC::Element.new(@sess, @ole_wrapper)
  end
  
  describe "#custom" do
    before(:each) do
      @data_ext = mock("QBFC::OLEWrapper#DataExtRet")
      @data_ext_list = [@data_ext, @data_ext]
      @ole_wrapper.stub!(:DataExtRetList).and_return(@data_ext_list)
      @ole_wrapper.stub!(:data_ext).and_return(@data_ext_list)
    end
  
    it "should get custom fields" do
      @data_ext.should_receive(:data_ext_name).and_return("Custom Field")
      @data_ext.should_receive(:owner_id).and_return(0)
      @data_ext.should_receive(:data_ext_value).and_return("Hello")
      
      @element.custom("Custom Field").should == "Hello"
    end
    
    it "should return nil if there are no custom fields" do
      @ole_wrapper.should_receive(:DataExtRetList).and_return(nil)
      
      @element.custom("Custom Field").should be_nil
    end
    
    it "should return nil if the custom field is not found" do
      @data_ext.should_receive(:data_ext_name).twice.and_return("Custom Field")
      
      @element.custom("No Field").should be_nil
    end
  end
end