require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module QBFC::Test
  class TxnVoid < QBFC::Transaction
    include QBFC::Voidable
    
    def qb_name
      "Check"
    end
  end
end

describe QBFC::Voidable do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    @txn = QBFC::Test::TxnVoid.new(@sess, @ole_wrapper)
  end

  describe "#void" do
    it "should call a TxnVoidRq with Txn Type and ID" do
      @void_rq = mock(QBFC::Request)
      @ole_wrapper.should_receive(:txn_id).and_return('{123-456}')
      QBFC::Request.should_receive(:new).with(@sess, "TxnVoid").and_return(@void_rq)
      @void_rq.should_receive(:txn_void_type=).with(QBFC_CONST::const_get("TvtCheck"))
      @void_rq.should_receive(:txn_id=).with("{123-456}")
      @void_rq.should_receive(:submit)
      @txn.void.should be_true
    end
  end
end