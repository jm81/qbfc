require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module QBFC::Test
  class BaseFind < QBFC::Element
    is_base_class
    
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
    @response = mock("QBFC::Request#response")
  end
  
  def setup_request
    QBFC::Request.should_receive(:new).with(@sess, 'CheckQuery').and_return(@request)
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
    
    it "should set request#max_returned to 1 if :first"

    it "should return an array if 'what' argument is :all" do
      setup_request
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
    it "passes additional arguments to Request"

    it "should get request#response" do
      setup_request
      @request.should_receive(:response).and_return(@response)    
      QBFC::Test::ElementFind::find(@sess, :first)
    end
  end
  
  describe ".query_for" do
    it "gets the OR*Query for the given Request" do
      @or_query = mock("OLEWrapper#or_query")
      @request.should_receive(:ole_methods).and_return(["TxnID", "RefNumber", "ORTransactionQuery", "OwnerIDList"])
      @request.should_receive(:ORTransactionQuery).and_return(@or_query)
      QBFC::Test::ListFind.__send__(:query_for, @request).should be(@or_query)
    end
  end
  
  describe ".filter_for" do
    it "gets the *Filter for the given Request" do
      @or_query = mock("OLEWrapper#or_query")
      @filter = mock("OLEWrapper#filter")
      
      @request.should_receive(:ole_methods).and_return(["TxnID", "RefNumber", "ORTransactionQuery", "OwnerIDList"])
      @request.should_receive(:ORTransactionQuery).and_return(@or_query)
      @or_query.should_receive(:ole_methods).and_return(["TxnIDList", "RefNumberList", "TransactionFilter"])
      @or_query.should_receive(:TransactionFilter).and_return(@filter)
      QBFC::Test::ListFind.__send__(:filter_for, @request).should be(@filter)
    end
  end
end
