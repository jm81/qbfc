require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe QBFC::QBCollection do

  before(:each) do
    @sess = mock(QBFC::Session)
  end

  it "should send missing methods to the Class specified, with the Session" do
    QBFC::Customer.should_receive(:find).with(@sess, :all)
    QBFC::QBCollection.new(@sess, 'Customer').find(:all)
  end
end