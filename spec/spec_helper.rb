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
    TMP_FILENAME = TMP_DIRNAME + "\\test.qbw"

    def initialize
      FileUtils.rm_rf(TMP_DIRNAME)
      FileUtils.cp_r FIXTURE_DIRNAME, TMP_DIRNAME
      filename = File.expand_path(TMP_FILENAME).gsub(/\//, "\\")
      puts filename
      @sess = QBFC::Session.new(:filename => filename)
    end
    
    def session
      @sess
    end
    
    def close
      @sess.close
      FileUtils.rm_rf(TMP_DIRNAME)
    end
  end
end