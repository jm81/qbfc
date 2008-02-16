require File.dirname(__FILE__) + '/../spec_helper'

describe "QBFC::Company" do

  before(:each) do 
    @integration = QBFC::Integration.new
    @sess = @integration.session
    @company = @sess.company
  end
  
  after(:each) do 
    @integration.close
  end

  it "should get name" do
    @company.company_name.should == "Test Company"
  end
  
  it "should get address" do
    @company.address.addr1.should == "123 Address St"
    @company.address.city.should == "Oklahoma City"
    @company.address.state.should == "OK"
    @company.address.postal_code.should == "73160"
  end
  
  it "should get phone" do
    @company.phone.should == "(555) 555-1212"
  end

end