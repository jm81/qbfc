require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
  
  it "should check if the OLE object responds to a given ole_method" do
    @ole_object.should_receive("ole_methods").twice.and_return(["FullName", "ListID"])
    @wrapper.respond_to_ole?(:FullName).should_not be_false
    @wrapper.respond_to_ole?(:NonMethod).should be_nil
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
      @ole_object.stub!(:ole_methods).and_return(['FullName', 'LineRetList', 'PayeeEntityRef', 'AccountRef', 'TimeModified', 'ListID', 'ORInvoiceLineRetList'])
    end
    
    it "should call a capitalized method directly" do
      @ole_object.should_receive(:TestValue).and_return(0)
      QBFC::OLEWrapper.should_not_receive(:new)
      
      @wrapper.qbfc_method_missing(@sess, :TestValue).should == 0
    end
    
    it "should call a capitalized method directly and wrap in OLEWrapper if it returns a WIN32OLE" do
      @full_name = WIN32OLE.new("QBFC6.QBSessionManager")
      @ole_object.should_receive(:FullName).and_return(@full_name)
      @full_name.should_not_receive(:GetValue)
      
      @full_name_wrapper = QBFC::OLEWrapper.new(@ole_object)
      QBFC::OLEWrapper.should_receive(:new).with(@full_name).and_return(@full_name_wrapper)
      
      @wrapper.qbfc_method_missing(@sess, :FullName).should == @full_name_wrapper
    end

    it "should act as a getter method" do
      @ole_object.should_receive(:FullName).and_return(@full_name)
      @full_name.should_receive(:GetValue).and_return('Full Name')
      
      @wrapper.qbfc_method_missing(@sess, :full_name).should == 'Full Name'
    end
         
    it "should convert 'Id' to 'ID' in getter" do
      @ole_object.should_receive(:ListID).and_return(@full_name)
      @full_name.should_receive(:GetValue).and_return('{123-456}')
      
      @wrapper.qbfc_method_missing(@sess, :list_id).should == '{123-456}'
    end
    
    it "should convert return of date/time getter methods to Time" do
      time_modified = @full_name
      @ole_object.should_receive(:TimeModified).and_return(time_modified)
      time_modified.should_receive(:GetValue).and_return('2007-01-01 10:00:00')
      
      ret = @wrapper.qbfc_method_missing(@sess, :time_modified)
      ret.should be_kind_of(Time)
      ret.strftime("%Y-%m-%d %H:%M:%S").should == '2007-01-01 10:00:00'
    end
    
    it "should wrap WIN32OLE objects returned by getter that don't respond to GetValue" do
      @full_name = WIN32OLE.new("QBFC6.QBSessionManager")
      @ole_object.should_receive(:FullName).and_return(@full_name)
      @full_name.should_receive(:ole_methods).and_return(['SetValue'])
      @full_name.should_not_receive(:GetValue)
      
      @full_name_wrapper = QBFC::OLEWrapper.new(@ole_object)
      QBFC::OLEWrapper.should_receive(:new).with(@full_name).and_return(@full_name_wrapper)
      
      @wrapper.qbfc_method_missing(@sess, :full_name).should == @full_name_wrapper
    end
    
    it "should wrap @setter if applicable when wrapping WIN32OLE objects returned by getter " do
      @setter = mock(WIN32OLE)
      @setter.should_receive("ole_methods").and_return(["FullName", "ListID"])
      @wrapper = QBFC::OLEWrapper.new(@ole_object, @setter)

      @full_name_getter = WIN32OLE.new("QBFC6.QBSessionManager")
      @full_name_setter = WIN32OLE.new("QBFC6.QBSessionManager")
      @ole_object.should_receive(:FullName).and_return(@full_name_getter)
      @full_name_getter.should_receive(:ole_methods).and_return(['SetValue'])
      @setter.should_receive(:FullName).and_return(@full_name_setter)
      
      @full_name_wrapper = QBFC::OLEWrapper.new(@full_name_getter, @full_name_setter)
      QBFC::OLEWrapper.should_receive(:new).with(@full_name_getter, @full_name_setter).and_return(@full_name_wrapper)
      
      @wrapper.qbfc_method_missing(@sess, :full_name).should == @full_name_wrapper
    end
    
    it "should return non-WIN32OLE returned by getter that don't respond to GetValue" do
      @ole_object.should_receive(:FullName).and_return('Full Name')
      @full_name.should_not_receive(:GetValue)
      @wrapper.qbfc_method_missing(@sess, :full_name).should == 'Full Name'
    end
    
    it "should act as a setter method" do
      @ole_object.should_receive(:FullName).and_return(@full_name)
      @full_name.should_receive(:SetValue).with('Full Name')
      
      @wrapper.qbfc_method_missing(@sess, :full_name=, 'Full Name')
    end

    it "should set @setter also when acting as a setter method, if applicable" do
      @setter = mock(WIN32OLE)
      @setter.should_receive("ole_methods").and_return(["FullName", "ListID"])
      @wrapper = QBFC::OLEWrapper.new(@ole_object, @setter)

      @full_name_setter = WIN32OLE.new("QBFC6.QBSessionManager")      
      @setter.should_receive(:FullName).and_return(@full_name_setter)
      @full_name.should_receive(:SetValue).with('Full Name')
      @full_name_setter.should_receive(:SetValue).with('Full Name')
      
      @wrapper.qbfc_method_missing(@sess, :full_name=, 'Full Name')
    end

    it "should convert 'Id' to 'ID' in setter" do
      @ole_object.should_receive(:ListID).and_return(@full_name)
      @full_name.should_receive(:SetValue).and_return('{123-456}')
      
      @wrapper.qbfc_method_missing(@sess, :list_id=, '{123-456}')
    end
    
    it "should raise SetValueMissing error on a setter call for a method without SetValue" do
      @ole_object.should_receive(:FullName).and_return(@full_name)
      @full_name.should_receive(:ole_methods).and_return(['GetValue'])
      
      lambda { @wrapper.qbfc_method_missing(@sess, :full_name=, 'Full Name') }.
        should raise_error(QBFC::SetValueMissing)
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
    
    it "should wrap OR*RetList objects in an Array" do
      ret_list = mock('WIN32OLE.ORInvoiceLineRetList')
      list_item_wrapper = mock('WIN32OLE.InvoiceLineRetWrapper')
      list_item = mock('WIN32OLE.InvoiceLineRet')
      ret_list.stub!(:ole_methods).and_return(['GetAt', 'Count'])
      ret_list.should_receive(:Count).and_return(2)
      ret_list.should_receive(:GetAt).with(0).and_return(list_item_wrapper)
      ret_list.should_receive(:GetAt).with(1).and_return(list_item_wrapper)
      list_item_wrapper.should_receive(:InvoiceLineRet).twice.and_return(list_item)
    
      @ole_object.should_receive(:ORInvoiceLineRetList).and_return(ret_list)
      
      @wrapper.qbfc_method_missing(@sess, :invoice_lines).should ==
        [list_item, list_item]
    end
    
    it "should have *_full_name for *Ref" do
      ref = mock('WIN32OLE.PayeeRef')
      @ole_object.should_receive(:AccountRef).and_return(ref)

      full_name = "Full Name"
      full_name_obj = mock('WIN32OLE.FullName')
      ref.should_receive(:FullName).and_return(full_name_obj)
      full_name_obj.should_receive(:GetValue).and_return(full_name)
      
      @wrapper.qbfc_method_missing(@sess, :account_full_name).should == full_name
    end
    
    it "should have *_id for *Ref" do
      ref = mock('WIN32OLE.PayeeRef')
      @ole_object.should_receive(:AccountRef).and_return(ref)

      list_id = "1"
      list_id_obj = mock('WIN32OLE.ListID')
      ref.should_receive(:ListID).and_return(list_id_obj)
      list_id_obj.should_receive(:GetValue).and_return(list_id)
      
      @wrapper.qbfc_method_missing(@sess, :account_id).should == list_id
    end
    
    it "should have *_full_name for *EntityRef" do
      ref = mock('WIN32OLE.PayeeEntityRef')
      @ole_object.should_receive(:PayeeEntityRef).and_return(ref)

      full_name = "Full Name"
      full_name_obj = mock('WIN32OLE.FullName')
      ref.should_receive(:FullName).and_return(full_name_obj)
      full_name_obj.should_receive(:GetValue).and_return(full_name)
      
      @wrapper.qbfc_method_missing(@sess, :payee_full_name).should == full_name
    end

    it "should have *_id for *EntityRef" do
      ref = mock('WIN32OLE.PayeeEntityRef')
      @ole_object.should_receive(:PayeeEntityRef).and_return(ref)

      list_id = "1"
      list_id_obj = mock('WIN32OLE.ListID')
      ref.should_receive(:ListID).and_return(list_id_obj)
      list_id_obj.should_receive(:GetValue).and_return(list_id)
      
      @wrapper.qbfc_method_missing(@sess, :payee_id).should == list_id
    end
    
    it "should create a Base-inherited object from a *EntityRef" do
      entity_ref = mock('WIN32OLE.PayeeEntityRef')
      @ole_object.should_receive(:PayeeEntityRef).and_return(entity_ref)

      list_id = "1"
      list_id_obj = mock('WIN32OLE.ListID')
      entity_ref.should_receive(:ListID).and_return(list_id_obj)
      list_id_obj.should_receive(:GetValue).and_return(list_id)
      
      entity = mock(QBFC::Entity)
      
      QBFC::Entity.should_receive(:find_by_id).with(@sess, list_id).and_return(entity)
      
      @wrapper.qbfc_method_missing(@sess, :payee).should == entity
    end
    
    it "should return nil for a *Ref if the ole_method calling *Ref returns nil" do
      @ole_object.should_receive(:PayeeEntityRef).and_return(nil)      
      @wrapper.qbfc_method_missing(@sess, :payee).should be_nil
    end
    
    it "should create a Base-inherited object from a *Ref" do
      account_ref = mock('WIN32OLE.AccountRef')
      @ole_object.should_receive(:AccountRef).and_return(account_ref)

      list_id = "1"
      list_id_obj = mock('WIN32OLE.ListID')
      account_ref.should_receive(:ListID).and_return(list_id_obj)
      list_id_obj.should_receive(:GetValue).and_return(list_id)
      
      account = mock(QBFC::Account)
      
      QBFC::Account.should_receive(:find_by_id).with(@sess, list_id).and_return(account)
      
      @wrapper.qbfc_method_missing(@sess, :account).should == account    
    end
    
    it "should raise NoMethodError if none of the above apply" do
      lambda { @wrapper.qbfc_method_missing(@sess, :no_method) }.should raise_error(NoMethodError, 'no_method')
    end
  end
end