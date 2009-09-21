require 'spec_helper'

module QBFC::Test
  class ListMod < QBFC::List
    include QBFC::Modifiable
    
    def self.qb_name
      "Account"
    end
  end

  class TxnMod < QBFC::Transaction
    include QBFC::Modifiable
    
    def self.qb_name
      "Check"
    end
  end
end

describe 'QBFC::Modifiable' do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    @ole_wrapper.stub!(:list_id).and_return "{list-id}"
    @ole_wrapper.stub!(:txn_id).and_return "{txn-id}"
    @ole_wrapper.stub!(:edit_sequence).and_return "123"
    @ole_wrapper.stub!(:setter=)

    @mod_rq = mock(QBFC::Request)
    @mod_ole = mock(WIN32OLE)
    @mod_rq.should_receive(:ole_object).and_return(@mod_ole)
    @mod_rq.stub!(:list_id=)
    @mod_rq.stub!(:txn_id=)
    @mod_rq.stub!(:edit_sequence=)
    QBFC::Request.stub!(:new).and_return(@mod_rq)
  end

  describe "#initialize" do
    it "should setup Mod Request for existing records" do
      QBFC::Request.should_receive(:new).with(@sess, "AccountMod").and_return(@mod_rq)
      QBFC::Test::ListMod.new(@sess, @ole_wrapper)
    end

    it "should not set Mod Request for new records" do
      QBFC::Request.should_not_receive(:new).with(@sess, "AccountMod")
      QBFC::Test::ListMod.new(@sess)
    end
  end
  
  describe "#setup_mod_request" do
  
    it "should create a Mod Request object" do
      QBFC::Request.should_receive(:new).with(@sess, "AccountMod").and_return(@mod_rq)
      QBFC::Test::ListMod.new(@sess, @ole_wrapper)
    end
    
    it "should set the Mod's id (for Lists) to the ole_object's id" do
      @mod_rq.should_receive(:list_id=).with("{list-id}")
      QBFC::Test::ListMod.new(@sess, @ole_wrapper)
    end
    
    it "should set the Mod's txn_id (for Transaction) to the ole_object's id" do
      @mod_rq.should_receive(:txn_id=).with("{txn-id}")
      QBFC::Test::TxnMod.new(@sess, @ole_wrapper)
    end

    it "should set the Mod's edit_sequence" do
      @mod_rq.should_receive(:edit_sequence=).with("123")
      QBFC::Test::TxnMod.new(@sess, @ole_wrapper)
    end
    
    it "should add the Mod request's ole_object as the @ole.setter" do
      @ole_wrapper.should_receive(:setter=).with(@mod_ole)
      QBFC::Test::TxnMod.new(@sess, @ole_wrapper)
    end
    
    it "should assign the Mod request as the @setter" do
      txn = QBFC::Test::TxnMod.new(@sess, @ole_wrapper)
      txn.instance_variable_get(:@setter).should be(@mod_rq)
    end
  end
end