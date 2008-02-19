require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module QBFC::Test
  class Txn < QBFC::Transaction
    def qb_name
      "Check"
    end
  end
end

describe QBFC::Transaction do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    @txn = QBFC::Test::Txn.new(@sess, @ole_wrapper)
  end

  describe "#id" do
    it "is an alias of txn_id" do
      @ole_wrapper.should_receive(:txn_id).and_return('T123')
      @txn.id.should == 'T123'
    end
  end
    
  describe "#delete" do
    it "should setup a TxnDelRq with Txn Type and ID" do
      @del_rq = mock(QBFC::Request)
      @ole_wrapper.should_receive(:txn_id).and_return('123-456')
      QBFC::Request.should_receive(:new).with(@sess, "TxnDel").and_return(@del_rq)
      @del_rq.should_receive(:txn_del_type=).with(QBFC_CONST::TdtCheck)
      @del_rq.should_receive(:txn_id=).with('123-456')
      @del_rq.should_receive(:submit)
      @txn.delete.should be_true
    end
  end
  
  describe "#display" do
    it "should call TxnDisplayAdd for new records"
    it "should call TxnDisplayMod for existing records"
  end
  
  describe "#cleared_status=" do
    before(:each) do
      @ole_wrapper.should_receive(:txn_id).and_return('123-456')
      
      @cs_rq = mock(QBFC::Request)
      QBFC::Request.should_receive(:new).with(@sess, "ClearedStatusMod").and_return(@cs_rq)
      @cs_rq.should_receive(:txn_id=).with('123-456')
      @cs_rq.should_receive(:submit)
    end
    
    it "should submit a ClearedStatusModRq" do
      @cs_rq.should_receive(:cleared_status=).with(QBFC_CONST::CsCleared)
      @txn.cleared_status = QBFC_CONST::CsCleared
    end
    
    it "should accept true for CsCleared" do
      @cs_rq.should_receive(:cleared_status=).with(QBFC_CONST::CsCleared)
      @txn.cleared_status = true
    end
    
    it "should accept false for CsNotCleared" do
      @cs_rq.should_receive(:cleared_status=).with(QBFC_CONST::CsNotCleared)
      @txn.cleared_status = false
    end

  end
end