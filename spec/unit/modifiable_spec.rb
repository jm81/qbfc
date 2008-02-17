require File.dirname(__FILE__) + '/../spec_helper'

describe QBFC::Modifiable do

  describe "#initialize" do
    it "should create a Mod Request object"
    it "should set the Mod's list_id or txn_id to the ole_object's id"
    it "should set the Mod's edit_sequence"
    it "should add the Mod request's ole_object as the @ole.setter"
    it "should assign the Mod request as the @setter"
  end
end