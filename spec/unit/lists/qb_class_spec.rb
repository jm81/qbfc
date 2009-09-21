require 'spec_helper'

describe QBFC::QBClass do

  it "should access QBFC 'Class' elements" do
    QBFC::QBClass.qb_name.should == "Class"
  end

end