require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module QBFC::Test
  class BaseFind < QBFC::Element
    is_base_class
    
    ID_NAME = "ListID"
    
    def self.qb_name
      "Entity"
    end
  end
  
  class ElementFind < QBFC::Element
    def self.qb_name
      "Check"
    end
  end
end

# An Element is a Transaction or a List; that is any QuickBooks objects that can
# be created, edited (possibly), deleted and read. Contrast to a Report or Info
# which are read-only.
describe QBFC::Element do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    @element = mock(QBFC::Test::ElementFind)
    
    # Request related mocks
    @request = mock("QBFC::Request")
    @request.stub!(:kind_of?).with(QBFC::Request).and_return(true)
    @request.stub!(:kind_of?).with(Hash).and_return(false)
    @response = mock("QBFC::Request#response")
    
    # Filter mock
    @filter = mock("QBFC::OLEWrapper#Filter")
    @request.stub!(:filter).and_return(@filter)
    @request.stub!(:add_limit)
    @request.stub!(:filter_available?).and_return(true)
    @request.stub!(:apply_options)
  end
  
  def setup_request
    QBFC::Request.stub!(:new).and_return(@request)
    @request.stub!(:response).and_return(@response)
    @response.stub!(:GetAt).and_return(@ole_wrapper)
    @response.stub!(:ole_methods).and_return(["GetAt"])
    @response.stub!(:Count).and_return(2)

    QBFC::Test::ElementFind.should_receive(:new).with(@sess, @ole_wrapper).at_least(:once).and_return(@element)
  end

  describe ".find" do
  
    it "should find_by_unique_id if the 'what' argument is neither :all nor :first" do
      QBFC::Test::ElementFind::should_receive(:find_by_unique_id).with(@sess, "123-456", {})
      QBFC::Test::ElementFind::find(@sess, "123-456", {})
    end
    
    it "should return only first entry if 'what' argument is :first" do  
      setup_request
      QBFC::Test::ElementFind::find(@sess, :first).should be(@element)
    end
    
    it "should set request#max_returned to 1 if :first" do
      setup_request
      @request.should_receive(:add_limit).with(1)
      @request.stub!(:filter_available?).and_return(true)
      QBFC::Test::ElementFind::find(@sess, :first)
    end

    it "should not set request#max_returned if not request.filter_available?" do
      setup_request
      @request.stub!(:filter_available?).and_return(false)
      @request.should_not_receive(:add_limit)
      QBFC::Test::ElementFind::find(@sess, :first)
    end

    it "should return an array if 'what' argument is :all" do
      setup_request
      @filter.should_not_receive(:max_returned=)
      QBFC::Test::ElementFind::find(@sess, :all).should == [@element, @element]
    end
    
    it "should return nil if no elements are found unless finding :first" do
      QBFC::Request.should_receive(:new).with(@sess, 'CheckQuery').and_return(@request)
      @request.should_receive(:response).and_return(nil)
      QBFC::Test::ElementFind::find(@sess, :first).should be_nil
    end
    
    it "should return an empty array if no elements are found when finding :all" do
      QBFC::Request.should_receive(:new).with(@sess, 'CheckQuery').and_return(@request)
      @request.should_receive(:response).and_return(nil)
      QBFC::Test::ElementFind::find(@sess, :first).should be_nil
    end
    
    it "can accept a Request object"
    it "generates a Request object if not given one"
    it "accepts conditions"
    
    it "applies options to request" do
      setup_request
      @request.should_receive(:apply_options).with({:owner_id => 0})
      QBFC::Test::ElementFind::find(@sess, :first, :owner_id => 0)
    end
    
    it "passes additional arguments to Request"

    it "should get request#response" do
      setup_request
      @request.should_receive(:response).and_return(@response)    
      QBFC::Test::ElementFind::find(@sess, :first)
    end
    
    it "should call base_class_find for base classes" do
      QBFC::Request.stub!(:new).and_return(@request)
      QBFC::Test::BaseFind.should_receive(:base_class_find).with(@sess, :first, @request, {}).and_return(@element)
      QBFC::Test::BaseFind::find(@sess, :first, {}).should be(@element)
    end
    
    it "should not call base_class_find for non-base classes" do
      setup_request
      QBFC::Test::ElementFind.should_not_receive(:base_class_find)
      QBFC::Test::ElementFind::find(@sess, :first, {})      
    end
  end

  describe ".base_class_find" do
    before(:each) do
      @request.stub!(:IncludeRetElementList).and_return(@include_list)
      @include_list.stub!(:Add).with("ListID")
      @request.stub!(:response).and_return(@response)
      QBFC::Request.stub!(:new).and_return(@request)
      
      @element = mock(QBFC::Test::ElementFind)
      @base_element = mock(QBFC::Test::BaseFind)
      @customer_ret = mock("CustomerRet")
      @list_id = mock("ListID")
      @base_element.stub!(:ole_methods).and_return(["VendorRet", "CustomerRet"])
      @base_element.stub!(:VendorRet).and_return(nil)
      @base_element.stub!(:CustomerRet).and_return(@customer_ret)
      @customer_ret.stub!(:ListID).and_return(@list_id)
      @list_id.stub!(:GetValue).and_return("123-456")
      QBFC::Customer.stub!(:find_by_id).and_return(@element)

      @response.stub!(:GetAt).and_return(@base_element)
      @response.stub!(:Count).and_return(2)
    end

    it "should request only ListID" do
      @include_list.should_receive(:Add).with("ListID")
      QBFC::Test::BaseFind.find(@sess, :first, @request, {})
    end
    
    it "should send class ChildList::find_by_id with ListID and find options for each" do
      @base_element.should_receive(:CustomerRet).at_least(:once).and_return(@customer_ret)
      @customer_ret.should_receive(:ListID).at_least(:once).and_return(@list_id)
      @list_id.should_receive(:GetValue).at_least(:once).and_return("789-012")
      QBFC::Customer.should_receive(:find_by_id).at_least(:once).with(@sess, "789-012", {}).and_return(@element)
      QBFC::Test::BaseFind.find(@sess, :first, @request, {}).should be(@element)
    end
    
    it "should return nil if no records and not :all" do
      @request.should_receive(:response).and_return(nil)
      QBFC::Test::BaseFind.find(@sess, :first, @request, {}).should be_nil
    end
    
    it "should return nil if no records and not :all" do
      @request.should_receive(:response).and_return(nil)
      QBFC::Test::BaseFind.find(@sess, :all, @request, {}).should == []
    end    
    
    it "should return single record unless :all" do
      QBFC::Test::BaseFind.find(@sess, :first, @request, {}).should be(@element)
    end
    
    it "should return Array if :all" do
      QBFC::Test::BaseFind.find(@sess, :all, @request, {}).should == [@element, @element]
    end
  end
end
