require 'rubygems'
gem 'rspec'
require 'spec'
require File.expand_path(File.dirname(__FILE__) + '/../lib/qbfc')

Spec::Runner.configure do |config|

end

module QBFC
  class Integration
    FIXTURE_DIRNAME = File.dirname(__FILE__) + "\\fixtures"
    FIXTURE_FILENAME = FIXTURE_DIRNAME + "\\test.qbw"
    TMP_DIRNAME = File.dirname(__FILE__) + "\\tmp"
    
    class << self
      def reader
        @@reader ||= new(true)
        @@reader.open_sess
        @@reader
      end
    end

    def initialize(is_reader = false)
      FileUtils.mkdir_p(TMP_DIRNAME)

      @is_reader = is_reader
      @@i ||= 0
      @@i += 1
      @dirname = TMP_DIRNAME + "\\fixture_#{@@i}"
      FileUtils.rm_rf(@dirname)
      FileUtils.mkdir_p(@dirname)
      
      ['lgb', 'qbw', 'qbw.ND', 'qbw.TLG'].each do |ext|
        FileUtils.cp FIXTURE_DIRNAME + "\\test.#{ext}", @dirname
      end
      
      open_sess
    end
    
    def filename
      File.expand_path(@dirname + "\\test.qbw").gsub(/\//, "\\")
    end
    
    def open_sess
      @sess = QBFC::Session.new(:filename => filename)
    end
    
    def session
      @sess
    end
    
    def close
      @sess.close
      sleep(1)
      unless @is_reader
        sleep(3)
        FileUtils.rm_rf(@dirname) 
      end
    end
  end

end