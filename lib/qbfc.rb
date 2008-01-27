require 'win32ole'
require 'time'

# ActiveSupport is used for camelize, singularize and similar String inflectors.
unless Object.const_defined?(:ActiveSupport)
  gem 'activesupport'
  require 'active_support'
end

module QBFC
  class << self
  
    def session(*args, &block)
      QBFC::Session::open(*args, &block)
    end
    
  end
end

%w{ ole_wrapper qbfc_const session request base qb_collection qb_types }.each do |file|
  require File.dirname(__FILE__) + '/qbfc/' + file
end

=begin
QBFC::session do | qb |
  request_set = qb.CreateMsgSetRequest("US", 6, 0)
  customer_query = request_set.AppendCustomerQueryRq

  response = qb.DoRequests(request_set)
  customer_set = response.ResponseList[0]
  first_customer = customer_set.Detail[0]
  puts first_customer.full_name
end

qb = QBFC::Session.new
request_set = qb.CreateMsgSetRequest("US", 6, 0)
customer_query = request_set.AppendCustomerQueryRq

response = qb.DoRequests(request_set)
customer_set = response.ResponseList[0]
first_customer = customer_set.Detail[0]
puts first_customer.full_name
qb.close

sess = QBFC::Session.new
customers = QBFC::Customer.find(sess, :all)
puts customers[0].full_name
puts QBFC::Customer.find(sess, :first).full_name
sess.close

QBFC::session do | qb |
  customers = qb.customers.find(:all)
  puts customers[0].full_name
  puts qb.customers.find(:first).full_name
end

QBFC::session do | qb |
  puts qb.customer('Haworth Homes').full_name
end

=end