require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

module QBFC::Test
  class List < QBFC::List
    def self.qb_name
      "Account"
    end
  end
end

describe QBFC::List do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    @list = QBFC::Test::List.new(@sess, @ole_wrapper)
  end
  
  it "should specify if it is a superclass_list (such as Entity)"
  
  describe "#id" do
    it "is an alias of list_id" do
      @ole_wrapper.should_receive(:list_id).and_return('L123')
      @list.id.should == 'L123'
    end
  end
  
  describe "#full_name" do
    before(:each) do
      @ole_wrapper.stub!(:full_name).and_return("Full Name")
      @ole_wrapper.stub!(:name).and_return("Short Name")
    end
    
    it "aliases name if not defined by OLE object" do
       @ole_wrapper.should_receive(:respond_to_ole?).with("FullName").and_return(false)
       @list.full_name.should == "Short Name"
    end
    
    it "calls OLE object's FullName method if defined" do
       @ole_wrapper.should_receive(:respond_to_ole?).with("FullName").and_return(true)
       @list.full_name.should == "Full Name"    
    end
  end
  
  describe "#delete" do
    it "should setup a ListDelRq with List Type and ID" do
      @del_rq = mock(QBFC::Request)
      @ole_wrapper.should_receive(:list_id).and_return('{123-456}')
      QBFC::Request.should_receive(:new).with(@sess, "ListDel").and_return(@del_rq)
      @del_rq.should_receive(:list_del_type=).with(QBFC_CONST::const_get("LdtAccount"))
      @del_rq.should_receive(:list_id=).with("{123-456}")
      @del_rq.should_receive(:submit)
      @list.delete.should be_true
    end
  end
  
  describe "#display" do
    before(:each) do
      @display_rq = mock(QBFC::Request)
    end
  
    it "should call ListDisplayAdd for new records" do
      QBFC::Request.should_receive(:new).with(@sess, "ListDisplayAdd").and_return(@display_rq)
      @display_rq.should_receive(:list_display_add_type=).with(QBFC_CONST::LdatAccount)
      @display_rq.should_receive(:submit)
      @list.instance_variable_set(:@new_record, true)
      @list.display
    end
    
    it "should call ListDisplayMod for existing records" do
      @ole_wrapper.should_receive(:list_id).and_return('123-456')

      QBFC::Request.should_receive(:new).with(@sess, "ListDisplayMod").and_return(@display_rq)
      @display_rq.should_receive(:list_display_mod_type=).with(QBFC_CONST::LdatAccount)
      @display_rq.should_receive(:list_id=).with('123-456')
      @display_rq.should_receive(:submit)
      @list.display
    end
  end
end