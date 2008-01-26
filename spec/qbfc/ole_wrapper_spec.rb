require File.dirname(__FILE__) + '/../spec_helper'

describe QBFC::OLEWrapper do
  
  before(:each) do
    @sess = mock(QBFC::Session)
    @ole_object = mock(WIN32OLE)
    @wrapper = QBFC::OLEWrapper.new(@ole_object)
  end

  it "should initialize with a WIN32OLE object" do
    lambda{ QBFC::OLEWrapper.new(@ole_object) }.should_not raise_error
  end
  
  it "should initialize with a String name a WIN32OLE server" do
    WIN32OLE.should_receive(:new).with("ServerName")
    QBFC::OLEWrapper.new("ServerName")
  end
  
  it "should return ole_methods" do
    @ole_object.should_receive("ole_methods").and_return([])
    @wrapper.ole_methods.should == []
  end
  
  it "should make a list responding to GetAt act as an Array" do
    @get_at_object = mock(WIN32OLE)
    @get_at_wrapper = QBFC::OLEWrapper.new(@get_at_object)
    
    @ole_object.should_receive("GetAt").with(1).and_return(@get_at_object)
    QBFC::OLEWrapper.should_receive(:new).with(@get_at_object).and_return(@get_at_wrapper)
    
    @wrapper[1].should == @get_at_wrapper
  end
  
  it "should pass non-integer values to [] on to ole_object" do
    @ole_object.should_receive("[]").with('1').and_return("Second Object")
    @wrapper['1'].should == "Second Object"  
  end
  
  describe "QBFC::OLEWrapper#qbfc_method_missing" do
  
    before(:each) do
      @sess = mock(QBFC::Session)
      @ole_object = mock(WIN32OLE)
      @wrapper = QBFC::OLEWrapper.new(@ole_object)
      
      @full_name = mock('WIN32OLE.FullName')
      @full_name.stub!(:ole_methods).and_return(['GetValue', 'SetValue'])
      
      @ole_object.stub!(:FullName).and_return(@full_name)
      @ole_object.stub!(:ole_methods).and_return(['FullName', 'LineRetList', 'PayeeEntityRef', 'AccountRef'])
    end

    it "should act as a getter method" do
      @ole_object.should_receive(:FullName).and_return(@full_name)
      @full_name.should_receive(:GetValue).and_return('Full Name')
      
      @wrapper.qbfc_method_missing(@sess, :full_name).should == 'Full Name'
    end
    
    it "should act as a setter method" do
      @ole_object.should_receive(:FullName).and_return(@full_name)
      @full_name.should_receive(:SetValue).with('Full Name')
      
      @wrapper.qbfc_method_missing(@sess, :full_name=, 'Full Name')
    end
    
    it "should wrap *RetList objects in an Array" do
      ret_list = mock('WIN32OLE.RetList')
      ret_list.stub!(:ole_methods).and_return(['GetAt', 'Count'])
      ret_list.should_receive(:Count).and_return(2)
      ret_list.should_receive(:GetAt).with(0).and_return(@full_name)
      ret_list.should_receive(:GetAt).with(1).and_return(@full_name)
    
      @ole_object.should_receive(:LineRetList).and_return(ret_list)
      
      @full_name_wrapper = QBFC::OLEWrapper.new(@full_name)
      QBFC::OLEWrapper.should_receive(:new).with(@full_name).twice.and_return(@full_name_wrapper)
      
      @wrapper.qbfc_method_missing(@sess, :lines).should ==
        [@full_name_wrapper, @full_name_wrapper]
    end
    
    it "should create a Base-inherited object from a *EntityRef" do
      entity_ref = mock('WIN32OLE.PayeeEntityRef')
      @ole_object.should_receive(:PayeeEntityRef).and_return(entity_ref)

      list_id = "1"
      list_id_obj = mock('WIN32OLE.ListID')
      entity_ref.should_receive(:ListID).and_return(list_id_obj)
      list_id_obj.should_receive(:GetValue).and_return(list_id)
      
      entity = mock(QBFC::Entity)
      
      QBFC::Entity.should_receive(:find_by_list_id).with(@sess, list_id).and_return(entity)
      
      @wrapper.qbfc_method_missing(@sess, :payee).should == entity
    end
    
    it "should create a Base-inherited object from a *Ref" do
      account_ref = mock('WIN32OLE.AccountRef')
      @ole_object.should_receive(:AccountRef).and_return(account_ref)

      list_id = "1"
      list_id_obj = mock('WIN32OLE.ListID')
      account_ref.should_receive(:ListID).and_return(list_id_obj)
      list_id_obj.should_receive(:GetValue).and_return(list_id)
      
      account = mock(QBFC::Account)
      
      QBFC::Account.should_receive(:find_by_list_id).with(@sess, list_id).and_return(account)
      
      @wrapper.qbfc_method_missing(@sess, :account).should == account    
    end
    
    it "should raise NoMethodError if none of the above apply" do
      lambda { @wrapper.qbfc_method_missing(@sess, :no_method) }.should raise_error(NoMethodError)
    end
  end
end