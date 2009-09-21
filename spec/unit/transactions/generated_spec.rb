require 'spec_helper'

describe "QBFC::Transactions generated.rb" do
  
  it "should generate classes" do
    QBFC::Check.superclass.should be(QBFC::Transaction)
    QBFC::Bill.superclass.should be(QBFC::Transaction)
    QBFC::CreditMemo.superclass.should be(QBFC::Transaction)
  end
  
  it "should include Voidable in voidable classes" do
    QBFC::Check.included_modules.should include(QBFC::Voidable)
    QBFC::Estimate.included_modules.should_not include(QBFC::Voidable)
  end
  
  it "should include Modifiable in modifiable classes" do
    QBFC::Check.included_modules.should include(QBFC::Modifiable)
    QBFC::Deposit.included_modules.should_not include(QBFC::Modifiable)
  end
end