require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QBFC::Item do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
  end

  it "is a base class" do
    QBFC::Item.is_base_class?.should be_true
  end
  
  describe ".find" do
    it "should return subclass objects"
  end
  
  describe ".add_special" do
    before(:each) do 
      @request = mock("QBFC::Request")
      @response = mock("QBFC::Request#response")
    end
    
    it "should add a Special Account" do
      QBFC::Request.should_receive(:new).with(@sess, "SpecialItemAdd").and_return(@request)
      @request.should_receive(:special_item_type=).with(QBFC_CONST::SitFinanceCharge)
      @request.should_receive(:response).and_return(@response)
  
      QBFC::Item.add_special(@sess, QBFC_CONST::SitFinanceCharge)
    end
  end
  
end