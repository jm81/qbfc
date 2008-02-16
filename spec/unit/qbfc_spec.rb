require File.dirname(__FILE__) + '/../spec_helper'

describe QBFC do

  it "should have a session method which calls QBFC::Session.open" do
    QBFC::Session.should_receive(:open).with({:filename => "file"})
    QBFC::session({:filename => "file"})
  end

end