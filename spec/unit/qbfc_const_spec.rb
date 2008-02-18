require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QBFC_CONST do

  it "should load QBFC constants" do
    QBFC_CONST::DmToday.should == 1
    QBFC_CONST::OmDontCare.should == 2
  end

end