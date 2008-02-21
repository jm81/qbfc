require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe QBFC::QBClass do

  it "should access QBFC 'Class' elements" do
    QBFC::QBClass.qb_name.should == "Class"
  end

end