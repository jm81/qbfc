require File.dirname(__FILE__) + '/../spec_helper'

# define some classes that inherit from Base with different "ALLOWS_*" constants
module QBFCSpec
  class Create < QBFC::Base
    ALLOWS_CREATE = true
  end

  class Read < QBFC::Base
    ALLOWS_READ = true
  end
  
  class Update < QBFC::Base
    ALLOWS_UPDATE = true
  end
  
  class Delete < QBFC::Base
    ALLOWS_DELETE = true
  end
  
  class Void < QBFC::Base
    ALLOWS_VOID = true
  end
end

describe QBFC::Base do

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
  
  it "should specify if it allows create operations" do
    QBFC::Base::allows_create?.should be_false
    QBFCSpec::Create::allows_create?.should be_true
  end

  it "should specify if it allows read operations" do
    QBFC::Base::allows_read?.should be_false
    QBFCSpec::Read::allows_read?.should be_true
  end
  
  it "should specify if it allows update operations" do
    QBFC::Base::allows_update?.should be_false
    QBFCSpec::Update::allows_update?.should be_true
  end
  
  it "should specify if it allows delete operations" do
    QBFC::Base::allows_delete?.should be_false
    QBFCSpec::Delete::allows_delete?.should be_true
  end
  
  it "should specify if it allows void operations" do
    QBFC::Base::allows_void?.should be_false
    QBFCSpec::Void::allows_void?.should be_true
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