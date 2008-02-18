require File.dirname(__FILE__) + '/../spec_helper'

module QBFC::Test
  class List < QBFC::List
    def qb_name
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

  describe ".find" do
    it "should find_by_name_or_id if the first argument is neither :all nor :first"
    it "should return only first entry if first argument is :first"
    it "should set request#max_returned to 1 if :first"
    it "should return an array if first argument is :all"
    it "should return nil if no elements are found unless finding :all"
    it "should return an empty array if no elements are found when finding :all"
    it "can accept a Request object"
    it "generates a Request object if not given one"
    it "accepts conditions"
    it "passes additional arguments to Request"
    it "should get request#response"
    
    describe ".find(for base_class Lists)" do 
      it "should request only ListID"
      it "should send class ChildList::find_by_id with ListID and find options for each"
    end  
  end
  
  describe ".find_by_name" do
    it "should set up Request, specifying FullNameList"
    it "should process Request"
  end
  
  describe ".find_by_id" do
    it "should set up Request, specifying ListIDList"
    it "should process Request"
  end
  
  describe ".find_by_name_or_id" do
    it "should try to find_by_id"
    it "should try to find_by_name if id fails"
    it "should return nil if both name and id return nil"
  end
  
  describe "#id" do
    it "is an alias of list_id" do
      @ole_wrapper.should_receive(:list_id).and_return('L123')
      @list.id.should == 'L123'
    end
  end
  
  describe "#full_name" do
    it "aliases name if not defined by OLE object"
    it "calls OLE object's FullName method if defined"
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
    it "should call ListDisplayAdd for new records"
    it "should call ListDisplayMod for existing records"
  end
end