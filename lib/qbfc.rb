require 'win32ole'
require 'time'

# ActiveSupport is used for camelize, singularize and similar String inflectors.
unless Object.const_defined?(:ActiveSupport)
  gem 'activesupport'
  require 'active_support'
end

module QBFC
  class << self
  
    # Opens and yields a QBFC::Session
    def session(*args, &block)
      QBFC::Session::open(*args, &block)
    end
    
  end
end

%w{ ole_wrapper qbfc_const session request base qb_collection qb_types }.each do |file|
  require File.dirname(__FILE__) + '/qbfc/' + file
end
