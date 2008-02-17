require File.dirname(__FILE__) + '/../spec_helper'

describe QBFC::Base do
  
  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    @ole_methods = ["FullName", "ListID"]
    @base = QBFC::Base.new(@sess, @ole_wrapper)
  end
  
  it "requires a QBFC:Session argument" do
    lambda {QBFC::Base.new()}.should raise_error
    lambda {QBFC::Base.new(@sess)}.should_not raise_error
  end
  
  it "initializes with an optional ole_object argument" do
    lambda {QBFC::Base.new(@sess, @ole_wrapper)}.should_not raise_error
  end
  
  it "should wrap (only) a WIN32OLE object in an OLEWrapper" do
    @ole_object = mock(WIN32OLE)
    @ole_object.should_receive(:kind_of?).with(WIN32OLE).and_return(true)
    QBFC::OLEWrapper.should_receive(:new).with(@ole_object).and_return(@ole_wrapper)

    QBFC::Base.new(@sess, @ole_object)
  end
  
  it "should not wrap non-WIN32OLE objects" do   
    @ole_wrapper.should_receive(:kind_of?).with(WIN32OLE).and_return(false)
    QBFC::OLEWrapper.should_not_receive(:new).with(@ole_object)

    QBFC::Base.new(@sess, @ole_wrapper)
  end
  
  it "lists OLE methods for OLEWrapper object" do
    @ole_wrapper.should_receive(:ole_methods).and_return(@ole_methods)
    @base.ole_methods.should be(@ole_methods)
  end
  
  it "has a respond_to_ole? method" do
    @ole_wrapper.should_receive(:respond_to_ole?).with("FullName").and_return(true)
    @base.respond_to_ole?("FullName").should be_true
    
    @ole_wrapper.should_receive(:respond_to_ole?).with("NoMethod").and_return(false)
    @base.respond_to_ole?("NoMethod").should be_false
  end
  
  it "should pass unknown method calls to OLEWrapper#qbfc_method_missing" do
    @ole_wrapper.should_receive(:qbfc_method_missing).with(@sess, :full_name=, "arg")
    @base.full_name = "arg"
  end
  
  it "has a qb_name class method" do
    QBFC::Base.qb_name.should == "Base"
  end
  
  it "aliases qb_name class method as an instance method" do
    @base.qb_name.should == QBFC::Base.qb_name
  end
end