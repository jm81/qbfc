require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
  
  it "should create_query" do
    QBFC::Request.should_receive(:new).with(@sess, "BaseQuery")
    QBFC::Base.__send__(:create_query, @sess)
  end
  
  it "should should respond to is_base_class? with false" do
    QBFC::Base.is_base_class?.should be_false
  end
  
  describe ".parse_find_args" do
    before(:each) do
      @options = {:include_items => true, :owner_id => 0, :conditions => {}}
    end
  
    it "should return a Request object if given one" do
      rq, opt, base_opt = QBFC::Test::ElementFind.__send__(:parse_find_args, @request, @options)
      rq.should be(@request)
      
      rq, opt, base_opt = QBFC::Test::ElementFind.__send__(:parse_find_args, @request)
      rq.should be(@request)
    end
    
    it "should return nil request if no Request given" do
      rq, opt, base_opt = QBFC::Test::ElementFind.__send__(:parse_find_args, @options)
      rq.should be_nil

      rq, opt, base_opt = QBFC::Test::ElementFind.__send__(:parse_find_args)
      rq.should be_nil
    end
    
    it "should return dup of options if given them" do
      rq, opt, base_opt = QBFC::Test::ElementFind.__send__(:parse_find_args, @request, @options)
      opt.should == @options
      
      rq, opt, base_opt = QBFC::Test::ElementFind.__send__(:parse_find_args, @options)
      opt.should == @options
    end
    
    it "should return an empty hash for options if not given them" do
      rq, opt, base_opt = QBFC::Test::ElementFind.__send__(:parse_find_args, @request)
      opt.should == {}
      
      rq, opt, base_opt = QBFC::Test::ElementFind.__send__(:parse_find_args)
      opt.should == {}
    end
    
    it "should return base_options if is_base_class?" do
      rq, opt, base_opt = QBFC::Test::BaseFind.__send__(:parse_find_args, {})
      base_opt.should == {}
    end
    
    it "should make base_options and options separate objects" do
      rq, opt, base_opt = QBFC::Test::BaseFind.__send__(:parse_find_args, @options)
      base_opt.should_not be(opt)
    end
    
    it "should return nil for base_options if isn't a base class" do
      rq, opt, base_opt = QBFC::Test::ElementFind.__send__(:parse_find_args, {})
      base_opt.should be_nil
    end
    
    it "should delete :conditions from base_options" do
      rq, opt, base_opt = QBFC::Test::BaseFind.__send__(:parse_find_args, @options)
      base_opt.should == {:include_items => true, :owner_id => 0}
    end

    it "should delete :owner_id from options if a base class" do
      rq, opt, base_opt = QBFC::Test::BaseFind.__send__(:parse_find_args, @options)
      opt.should == {:include_items => true, :conditions => {}}    
    end
    
    it "should not delete :owner_id if not a base class" do
      rq, opt, base_opt = QBFC::Test::ElementFind.__send__(:parse_find_args, @options)
      opt.should == {:include_items => true, :owner_id => 0, :conditions => {}}
    end
  end
end