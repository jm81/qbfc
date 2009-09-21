require 'spec_helper'

describe "QBFC::Terms generated.rb" do
  
  it "should generate classes" do
    QBFC::DateDrivenTerms.superclass.should be(QBFC::Terms)
    QBFC::StandardTerms.superclass.should be(QBFC::Terms)
  end
  
  it "should not include Modifiable in any classes" do
    QBFC::DateDrivenTerms.included_modules.should_not include(QBFC::Modifiable)
    QBFC::StandardTerms.included_modules.should_not include(QBFC::Modifiable)
  end
end