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
      
      # Find a QuickBooks record for the given session. 
      # 
      # session.[qb_name] aliases this functionality. The following
      # pairs are equivalent:
      # 
      #   QBFC::Vendor.find(session, :first) <-> session.vendor
      #   QBFC::Vendor.find(session, "Supply Shop") <-> session.vendor("Supply Shop")
      #   QBFC::Vendor.find(session, :all) <-> session.vendors.find(:all)
      # 
      # Find requires a +session+ (representing a QBFC::Session) and
      # a +what+ argument. +what+ can be one of:
      # - <tt>:first</tt> - finds the first record fitting any given conditions.
      # - <tt>:finds</tt> - finds all records fitting any given conditions.
      # - An unique identifier, such as a ListID, FullName, RefNumber or TxnID
      # 
      # .find can also receive a optional Request object followed 
      # by an optional options Hash. Valid argument sets are:
      # 
      #   QBFC::Vendor.find(session, :first)
      #   QBFC::Vendor.find(session, :first, request)
      #   QBFC::Vendor.find(session, :first, request, options)
      #   QBFC::Vendor.find(session, :first, options)
      # 
      # The options hash accepts the following:
      # - <tt>:owner_id</tt>: One or more OwnerIDs, used in accessing
      #   custom fields (aka private data extensions).
      # 
      # Additional options are planned, but not really supported in this version.
      # Passing a Request object is the current recommended way of applying
      # Filters or other options to the Query Request.
      def find(sess, what, *args)
        
        if what.kind_of?(String) # Single FullName or ListID
          return find_by_unique_id(sess, what, *args)
        end
        
        # Setup q, options and base_options arguments
        q, options, base_options = parse_find_args(*args)
        q ||= create_query(sess)
        q.apply_options(options)
        
        # QuickBooks only needs to return one record if .find is
        # only returning a single record.
        if what == :first && q.filter_available?
          q.filter.max_returned = 1
        end
        
        # Send the query so far to base_class_find if this is
        # a base class to handle special base class functionality.
        return base_class_find(sess, what, q, base_options) if is_base_class?
        
        # Get response and return an Array, a QBFC::Element-inherited
        # object, or nil, depending on <tt>what</tt> argument and whether
        # the query returned any records.
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
      
      # Base classes can be used to find members of any of their
      # inherited classes. Since QuickBooks has limited options
      # for these type of queries (in particular, no custom fields
      # are returned), an initial query is run which retrieves
      # only IDs and the class type and then individual subsequent
      # queries are run for each returned object.
      def base_class_find(sess, what, q, options)
        q.IncludeRetElementList.Add(self::ID_NAME)
        list = q.response
        
        if list.nil?
          (what == :all) ? [] : nil
        else
          ary = (0..(list.Count - 1)).collect { |i|
            element = list.GetAt(i)
            ret_name = element.ole_methods.detect { |m|
              m.to_s =~ /(.*)Ret\Z/ && element.send(m.to_s)
            }.to_s
            ret_class = QBFC::const_get($1)
            ret_class.find(sess, element.send(ret_name).send(ret_class::ID_NAME).GetValue, options.dup)
          }
          
          if what == :all
            ary
          else
            ary[0]
          end
        end
      end
      
      private :base_class_find

    end
    
    is_base_class
    
    # Extends Base#initialize to allow for an Add Request if
    # .new is called directly (instead of by .find)
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
