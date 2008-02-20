require File.dirname(__FILE__) + '/modifiable'

module QBFC

  # An Element is a Transaction or a List; that is any QuickBooks objects that can
  # be created, edited (possibly), deleted and read. Contrast to a Report or Info
  # which are read-only.
  # 
  # Inheritance from Element implies a set of shared methods, such as find, but the
  # only shared implementation defined here is #custom, for getting custom field information.
  class Element < Base

    class << self
      # Set that this is a "base class", one which is inherited,
      # such as List, Transaction, Entity, or Terms.
      # Base classes do not accept Add Requests, and their finders
      # will return an instance of an inherited class.
      def is_base_class
        @is_base_class = true
      end
      
      # Check if this is a "base class" (see is_base_class)
      def is_base_class?
        @is_base_class ? true : false
      end
      
      def find(sess, what, *args)
        if what.kind_of?(String) # Single FullName or ListID
          return find_by_unique_id(sess, what, *args)
        end

        q = find_base(sess, what, *args)
        list = q.response
        
        if list.nil?
          (what == :all) ? [] : nil
        elsif what == :all
          (0..(list.Count - 1)).collect { |i|
            new(sess, list.GetAt(i))
          }
        else
          new(sess, list.GetAt(0))
        end
      end
      
      # Get the OR*Query object of the given Request
      # For example, the ORListQuery
      def query_for(rq) #:nodoc:
        query_name = rq.ole_methods.detect{|m| m.to_s =~ /Query\Z/}
        rq.send(query_name.to_sym)
      end

      # Get the *Filter object of the given Request
      # For example, the ListFilter
      def filter_for(rq) #:nodoc:
        q = query_for(rq)
        filter_name = q.ole_methods.detect{|m| m.to_s =~ /Filter\Z/}
        q.send(filter_name.to_sym)
      end
      
      protected :query_for, :filter_for

    end
    
    is_base_class
    
    def initialize(sess, ole_object = nil)
      if self.class.is_base_class?
        raise BaseClassNewError, "This is a base class which doesn't allow object initialization"
      end
      
      super
      
      if @ole.nil?
        add_rq = QBFC::Request.new(sess, "#{qb_name}Add")
        @ole = QBFC::OLEWrapper.new(add_rq.ole_object)
        @new_record = true
        @setter = add_rq
      end
    end
    
    # Is this a new record, i.e. are we doing an Add Request?
    def new_record?
      @new_record ? true : false
    end
  
    # Access information from a custom field.
    def custom(field_name, owner_id = 0)
      if @ole.DataExtRetList
        @ole.data_ext.each do |field|
          if field.data_ext_name == field_name && field.owner_id == owner_id
            return field.data_ext_value
          end
        end
      end
      
      return nil
    end
    
    # Save (create or update) this record
    def save
      if @setter
        @setter.submit
      else
        raise NotSavableError, "This record cannot be saved (Probably because it does not support Mod Requests)."
      end
    end
    
  end
end

# Require subclass files
%w{ list transaction }.each do |file|
  require File.dirname(__FILE__) + '/' + file
end
