require 'rubygems'
gem 'rspec'
require 'spec'
require File.dirname(__FILE__) + '/../lib/qbfc'

Spec::Runner.configure do |config|

end

module QBFC
  class Integration
    FIXTURE_DIRNAME = File.dirname(__FILE__) + "\\fixtures"
    FIXTURE_FILENAME = FIXTURE_DIRNAME + "\\test.qbw"
    TMP_DIRNAME = File.dirname(__FILE__) + "\\tmp"

    def initialize
      FileUtils.mkdir_p(TMP_DIRNAME)

      @@i ||= 0
      @@i += 1
      @dirname = TMP_DIRNAME + "\\fixture_#{@@i}"
      FileUtils.rm_rf(@dirname)
      FileUtils.mkdir_p(@dirname)

      FileUtils.cp_r FIXTURE_DIRNAME + "\\.", @dirname
      filename = File.expand_path(@dirname + "\\test.qbw").gsub(/\//, "\\")
      @sess = QBFC::Session.new(:filename => filename)
    end
    
    def session
      @sess
    end
    
    def close
      @sess.close
      sleep(5)
      FileUtils.rm_rf(@dirname)
    end
  end

end