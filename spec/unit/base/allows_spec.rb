require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

# define some classes that inherit from Base with different "ALLOWS_*" constants
module QBFCSpec  
  class Update < QBFC::Base
    ALLOWS_UPDATE = true
  end

end

describe "QBFC::Base::allows_*" do
    
  it "should specify if it allows update operations" do
    QBFC::Base::allows_update?.should be_false
    QBFCSpec::Update::allows_update?.should be_true
  end

end