require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module QBFC::Test
  class TxnFind < QBFC::Transaction
    def self.qb_name
      "Check"
    end
  end
end

describe QBFC::Transaction do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    @txn = QBFC::Test::Txn.new(@sess, @ole_wrapper)
    
    # Request related mocks
    @request = mock("QBFC::Request")
    @txn_query = mock("QBFC::OLEWrapper#txn_query")
    @response = mock("QBFC::Request#response")
    
    # Filter mock
    @filter = mock("QBFC::OLEWrapper#Filter")
    @request.stub!(:filter).and_return(@filter)
    @filter.stub!(:max_returned=)
  end
  
  def setup_request
    QBFC::Request.should_receive(:new).with(@sess, 'CheckQuery').and_return(@request)
    @request.should_receive(:kind_of?).with(QBFC::Request).and_return(true)
    @request.stub!(:response).and_return(@response)
    @response.stub!(:GetAt).with(0).and_return(@ole_wrapper)
    @response.stub!(:ole_methods).and_return(["GetAt"])
  end

  describe ".find" do   
    describe ".find(for base_class Txns)" do 
      it "should request only TxnID"
      it "should send class ChildTxn::find_by_id with TxnID and find options for each"
    end  
  end
  
  describe ".find_by_ref" do
    before(:each) do 
      @ref_list = mock("QBFC::OLEWrapper#ref_list")
    end
    
    def setup_request
      super
      @request.should_receive(:ORTxnQuery).and_return(@txn_query)
      @txn_query.should_receive(:RefNumberList).and_return(@ref_list)
      @ref_list.should_receive(:Add).with("12345")
    end
    
    it "should set up Request, specifying RefNumberList" do
      setup_request
      QBFC::Test::TxnFind.find_by_ref(@sess, "12345")
    end
  
    it "should return a Transaction object" do
      setup_request
      list = QBFC::Test::TxnFind.find_by_ref(@sess, "12345")
      list.should be_kind_of(QBFC::Test::TxnFind)
    end
  
    it "should return nil if none found" do
      setup_request
      @request.should_receive(:response).and_return(nil)
      QBFC::Test::TxnFind.find_by_ref(@sess, "12345").should be_nil
    end
  end
  
  describe ".find_by_id" do
    before(:each) do 
      @txn_id_list = mock("QBFC::OLEWrapper#txn_id_list")
    end
    
    def setup_request
      super
      @request.should_receive(:ORTxnQuery).and_return(@txn_query)
      @txn_query.should_receive(:TxnIDList).and_return(@txn_id_list)
      @txn_id_list.should_receive(:Add).with("123-456")
    end
    
    it "should set up Request, specifying TxnIDTxn" do
      setup_request
      QBFC::Test::TxnFind.find_by_id(@sess, "123-456")
    end
  
    it "should return a Transaction object" do
      setup_request
      list = QBFC::Test::TxnFind.find_by_id(@sess, "123-456")
      list.should be_kind_of(QBFC::Test::TxnFind)
    end
  
    it "should return nil if none found" do
      setup_request
      @request.should_receive(:response).and_return(nil)
      QBFC::Test::TxnFind.find_by_id(@sess, "123-456").should be_nil
    end
  end
  
  describe ".find_by_name_or_id" do    
    it "should try to find_by_id" do
      QBFC::Test::TxnFind.should_receive(:find_by_id).with(@sess, "123-456").and_return("Txn By ID")
      QBFC::Test::TxnFind.find_by_ref_or_id(@sess, "123-456").should == "Txn By ID"
    end
    
    it "should try to find_by_ref if id fails" do
      QBFC::Test::TxnFind.should_receive(:find_by_id).with(@sess, "123-456").and_return(nil)
      QBFC::Test::TxnFind.should_receive(:find_by_ref).with(@sess, "123-456").and_return("Txn By Ref")
      QBFC::Test::TxnFind.find_by_ref_or_id(@sess, "123-456").should == "Txn By Ref"
    end
    
    it "should return nil if both ref and id return nil" do
      QBFC::Test::TxnFind.should_receive(:find_by_id).with(@sess, "123-456").and_return(nil)
      QBFC::Test::TxnFind.should_receive(:find_by_ref).with(@sess, "123-456").and_return(nil)
      QBFC::Test::TxnFind.find_by_ref_or_id(@sess, "123-456").should be_nil
    end

    it "should be aliased as .find_by_unique_id" do
      QBFC::Test::TxnFind.should_receive(:find_by_id).with(@sess, "123-456").and_return(nil)
      QBFC::Test::TxnFind.should_receive(:find_by_ref).with(@sess, "123-456").and_return(nil)
      QBFC::Test::TxnFind.find_by_unique_id(@sess, "123-456").should be_nil
    end
  end
  
end