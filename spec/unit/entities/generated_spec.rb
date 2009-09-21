require 'spec_helper'

describe "QBFC::Entity generated.rb" do
  
  it "should generate classes" do
    QBFC::Customer.superclass.should be(QBFC::Entity)
    QBFC::Vendor.superclass.should be(QBFC::Entity)
    QBFC::OtherName.superclass.should be(QBFC::Entity)
    QBFC::Employee.superclass.should be(QBFC::Entity)
  end
  
  it "should include Modifiable in all classes" do
    QBFC::Customer.included_modules.should include(QBFC::Modifiable)
    QBFC::Vendor.included_modules.should include(QBFC::Modifiable)
    QBFC::OtherName.included_modules.should include(QBFC::Modifiable)
    QBFC::Employee.included_modules.should include(QBFC::Modifiable)
  end
end