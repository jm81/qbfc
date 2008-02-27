require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

# This spec describes use of the :conditions option to Element.find
# The implementation that this tests is Request#apply_options

describe "conditions: " do

  before(:each) do 
    @integration = QBFC::Integration::reader
    @sess = @integration.session
  end
  
  after(:each) do 
    @integration.close
  end
  
  describe "Check" do
    it "should limit records returned" do
      checks = @sess.checks.find(:all, :limit => 2)
      checks.length.should == 2
    end
    
    it "should filter on date range" do
      @sess.checks.find(:all, :conditions => {:txn_date_range => '2007-02-23'..'2007-02-25'}).length.should == 2
      @sess.checks.find(:all, :conditions => {:txn_date_range => '2007-02-26'}).length.should == 3
      @sess.checks.find(:all, :conditions => {:txn_date_range => Date.parse('2007-02-26')}).length.should == 3
    end
    
    it "should filter on modified time" do
      @sess.checks.find(:all, :conditions => {:modified_date_range => '2007-02-23'..'2007-02-25'}).length.should == 2
      @sess.checks.find(:all, :conditions => {:modified_date_range => '2007-02-26'}).length.should == 3
      @sess.checks.find(:all, :conditions => {:modified_date_range => Date.parse('2007-02-26')}).length.should == 3
    end
    
    it "should filter on ref number criteria" do
      checks = @sess.checks.find(:all, :conditions => {:ref_number_list => %w{1000 1002}})
      checks.length.should == 2
      checks[0].ref_number.should == '1000'
      checks[1].ref_number.should == '1002'
    end
    
    it "should filter on ref number range" do
      @sess.checks.find(:all, :conditions => {:ref_number_range => '1000'..'1001'}).length.should == 2
      @sess.checks.find(:all, :conditions => {:ref_number_range => '1003'}).length.should == 1
    end
    
    it "should filter on Entity" do
      @sess.checks.find(:all, :conditions => {:entity => 'ABC Supplies'}).length.should >= 2
      @sess.checks.find(:first, :conditions => {:entity => 'Computer Shop'}).ref_num.should == '1002'
    end
    
    it "should filter on Account" do
      @sess.checks.find(:all, :conditions => {:account => 'Checking'}).length.should >= 4
      @sess.checks.find(:all, :conditions => {:account => 'Accounts Receivable'}).length.should == 0
    end
  end
  
end