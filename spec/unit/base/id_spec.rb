require File.dirname(__FILE__) + '/../../spec_helper'

describe "QBFC::Base#id" do

  before(:each) do 
    # @ole_object represents the @ole_object in the class descended from
    # Base. Some specs will be checking that this is sent a 'qbfc_method_missing'
    # message with a given set of arguments. For specs that translate those
    # arguments correct, see OLEWrapper spec.
    @sess = mock(QBFC::Session)
    @ole_object = mock(QBFC::OLEWrapper)
    @ole_object.should_receive(:kind_of?).with(QBFC::OLEWrapper).and_return(true)
    @base = QBFC::Base.new(@sess, @ole_object)
  end
  
  it "should alias txn_id as id for transaction" do
    @ole_object.should_receive(:respond_to_ole?).with(:TxnID).and_return(true)
    @ole_object.should_receive(:respond_to_ole?).with(:ListID).and_return(false)
    @ole_object.should_receive(:txn_id).and_return('T123')
    @base.id.should == 'T123'
  end
  
  it "should alias list_id as id for list items" do
    @ole_object.should_receive(:respond_to_ole?).with(:ListID).and_return(true)
    @ole_object.should_receive(:list_id).and_return('L123')
    @base.id.should == 'L123'
  end
  
end