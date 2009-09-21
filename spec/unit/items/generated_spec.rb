require 'spec_helper'

describe "QBFC::Item generated.rb" do
  
  it "should generate classes" do
    QBFC::ItemGroup.superclass.should be(QBFC::Item)
    QBFC::ItemDiscount.superclass.should be(QBFC::Item)
    QBFC::ItemPayment.superclass.should be(QBFC::Item)
  end
  
  it "should include Modifiable in all classes" do
    QBFC::ItemGroup.included_modules.should include(QBFC::Modifiable)
    QBFC::ItemDiscount.included_modules.should include(QBFC::Modifiable)
    QBFC::ItemPayment.included_modules.should include(QBFC::Modifiable)
  end
end