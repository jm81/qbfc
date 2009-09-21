require 'spec_helper'

module QBFC::Test
  class BaseKlass < QBFC::Element
    is_base_class
  end
  
  class NormalKlass < QBFC::Element
  end
end

# An Element is a Transaction or a List; that is any QuickBooks objects that can
# be created, edited (possibly), deleted and read. Contrast to a Report or Info
# which are read-only.
describe QBFC::Element do

  before(:each) do 
    @sess = mock(QBFC::Session)
    @ole_wrapper = mock(QBFC::OLEWrapper)
    @ole_object = mock(WIN32OLE)
    @ole_methods = ["FullName", "DataExtRetList"]
    @element = QBFC::Test::NormalKlass.new(@sess, @ole_wrapper)
  end

  describe "#initialize" do
    it "should set up add request if ole_object is nil" do
      @request = mock(QBFC::Request)
      @request.should_receive(:ole_object).and_return(@ole_object)
      QBFC::Request.should_receive(:new).with(@sess, "NormalKlassAdd").and_return(@request)
      QBFC::Test::NormalKlass.new(@sess)
    end
    
    it "should assign the Add request as the @setter" do
      @request = mock(QBFC::Request)
      @request.stub!(:ole_object).and_return(@ole_object)
      QBFC::Request.should_receive(:new).with(@sess, "NormalKlassAdd").and_return(@request)
      QBFC::Test::NormalKlass.new(@sess).
          instance_variable_get(:@setter).should == @request
    end
  end
  
  describe "#new_record?" do
    before(:each) do
      @request = mock(QBFC::Request)
      @request.stub!(:ole_object).and_return(@ole_object)
      QBFC::Request.stub!(:new).with(@sess, "NormalKlassAdd").and_return(@request)
    end
    
    it "should return true if ole_object is an AddRq" do
      QBFC::Test::NormalKlass.new(@sess).new_record?.should be_true
    end

    it "should return false if ole_object is from a QueryRq" do
      @element.new_record?.should be_false
    end
  end
  
  describe ".is_base_class? (and is_base_class macro)" do
    it "should return true if Class is_base_class has been called" do
      QBFC::Test::BaseKlass.is_base_class?.should be_true
      QBFC::Test::NormalKlass.is_base_class?.should be_false
    end
  end
  
  describe "#custom" do
    before(:each) do
      @data_ext = mock("QBFC::OLEWrapper#DataExtRet")
      @data_ext_list = [@data_ext, @data_ext]
      @ole_wrapper.stub!(:DataExtRetList).and_return(@data_ext_list)
      @ole_wrapper.stub!(:data_ext).and_return(@data_ext_list)
    end
  
    it "should get custom fields" do
      @data_ext.should_receive(:data_ext_name).and_return("Custom Field")
      @data_ext.should_receive(:owner_id).and_return('0')
      @data_ext.should_receive(:data_ext_value).and_return("Hello")
      
      @element.custom("Custom Field").should == "Hello"
    end
    
    it "should return nil if there are no custom fields" do
      @ole_wrapper.should_receive(:DataExtRetList).and_return(nil)
      
      @element.custom("Custom Field").should be_nil
    end
    
    it "should return nil if the custom field is not found" do
      @data_ext.should_receive(:data_ext_name).twice.and_return("Custom Field")
      
      @element.custom("No Field").should be_nil
    end
  end
  
  describe "#save" do
    it "should submit the setter object" do
      @request = mock(QBFC::Request)
      @request.stub!(:ole_object).and_return(@ole_object)
      QBFC::Request.should_receive(:new).with(@sess, "NormalKlassAdd").and_return(@request)
      @request.should_receive(:submit)

      QBFC::Test::NormalKlass.new(@sess).save
    end
    
    it "should raise an error if there is no setter object" do
      lambda { @element.save}.should raise_error(QBFC::NotSavableError)
    end
  end
end