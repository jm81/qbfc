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
    @ole_object = mock('OLEWrapper')
    @base = QBFC::Base.new(@ole_object)
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
  
end