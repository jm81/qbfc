require 'spec_helper'

describe QBFC::Account do

 before(:each) do 
    @sess = mock(QBFC::Session)
    @request = mock("QBFC::Request")
    @response = mock("QBFC::Request#response")
  end
  
  it "should add a Special Account" do
    QBFC::Request.should_receive(:new).with(@sess, "SpecialAccountAdd").and_return(@request)
    @request.should_receive(:special_account_type=).with(QBFC_CONST::SatAccountsReceivable)
    @request.should_receive(:response).and_return(@response)
    QBFC::Account.should_receive(:new).with(@sess, @response)

    QBFC::Account.add_special(@sess, QBFC_CONST::SatAccountsReceivable)
  end

end