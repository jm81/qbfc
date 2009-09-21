require 'spec_helper'

describe "QBFC::Info generated.rb" do
  
  it "should generate classes" do
    QBFC::Company.superclass.should be(QBFC::Info)
    QBFC::CompanyActivity.superclass.should be(QBFC::Info)
    QBFC::Host.superclass.should be(QBFC::Info)
    QBFC::Preferences.superclass.should be(QBFC::Info)
  end
  
end