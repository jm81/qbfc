require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe "QBFC::List generated.rb" do
  
  it "should generate classes" do
    QBFC::Customer.ancestors.should include(QBFC::List)
    QBFC::Account.ancestors.should include(QBFC::List)
    QBFC::Account.superclass.should be(QBFC::List)
  end
  
  it "should include Modifiable in modifiable classes" do
    QBFC::Customer.included_modules.should include(QBFC::Modifiable)
    QBFC::CustomerMsg.included_modules.should_not include(QBFC::Modifiable)
  end
end