module QBFC

  # OLEWrapper is more or less the centerpiece of RubyQBFC. (Nearly) every
  # WIN32OLE object accessed within the library is wrapped in this class, which
  # is responsible for allowing Ruby-esque methods in place of the OLE methods.
  # 
  #   customer.full_name # => Customer.FullName.GetValue
  #   customer.full_name=(val) # => Customer.FullName.SetValue(val)
  #   
  # It also creates referenced objects when accessed.
  # 
  #   check.payee # => Entity.find_by_list_id(check.PayeeEntityRef.ListID.GetValue)
  #   check.account # => Account.find_by_list_id(check.AccountRef.ListID.GetValue)
  # 
  # When an OLE method called via OLEWrapper returns a WIN32OLE object, a new
  # OLEWrapper object is created with the WIN32OLE object and returned.
  class OLEWrapper
    attr_reader :ole_object
  
    # Set up wrapped object, by passing a WIN32OLE object
    # (or a String with the name of a WIN32OLE server)
    def initialize(ole_object)
      ole_object = WIN32OLE.new(ole_object) if ole_object.kind_of?(String)
      @ole_object = ole_object
    end
    
    # Return Array of ole_methods for request WIN32OLE object.
    def ole_methods
      @ole_object.ole_methods
    end
    
    # Does this OLE object respond to the given ole method?
    def respond_to_ole?(symbol)
      detect_ole_method?(@ole_object, symbol)
    end
    
    # Use [idx] syntax for objects that respond to <tt>GetAt(idx)</tt>
    def [](idx)
      if idx.kind_of? Integer
        self.class.new(@ole_object.GetAt(idx))
      else
        @ole_object[idx]
      end
    end
  
    # Called by #method_missing of other classes. Initiates the OLEWrapper#method_missing
    # method which is responsible for the various method conversions.
    # +sess+ argument is a QBFC::Session.
    def qbfc_method_missing(sess, symbol, *params)
      @sess = sess
      method_missing(symbol, *params)
    end
  
    # If the method name is capitalized, send directly to ole_object; if
    # a WIN32OLE is returned, wrap it.
    # If the method name starts with a lower-case letter, send to +lower_method_missing+
    # for conversion.
    def method_missing(symbol, *params) #:nodoc:
      if (('a'..'z') === symbol.to_s[0].chr)
        lower_case_method_missing(symbol, *params)
      else
        resp = @ole_object.send(symbol, *params)
        return( resp.kind_of?(WIN32OLE) ?
          self.class.new(resp) :
          resp )
      end
    end
    
    private

    # Decide which conversion method needs to handle this method and send.
    def lower_case_method_missing(symbol, *params)
      if '=' == symbol.to_s[-1].chr
        set_value(symbol.to_s[0..-2], *params)
      elsif detect_ole_method?(@ole_object, symbol.to_s.camelize.gsub(/Id/, 'ID'))
        get_value(symbol, *params)
      elsif detect_ole_method?(@ole_object, (s = symbol.to_s.singularize.camelize + "RetList"))
        setup_array(s)
      elsif detect_ole_method?(@ole_object, symbol.to_s.camelize + "EntityRef")
        create_ref(symbol, true, *params)
      elsif detect_ole_method?(@ole_object, symbol.to_s.camelize + "Ref")
        create_ref(symbol, false, *params)
      else
        raise NoMethodError, symbol.to_s
      end 
    end
    
    # Sets a value by calling OLEMethodName.SetValue(*params)
    def set_value(ole_method_name, *params)
      obj = @ole_object.send(ole_method_name.to_s.camelize.gsub(/Id/, 'ID'))

      if detect_ole_method?(obj, "SetValue")
        obj.SetValue(*params)
      else
        raise SetValueMissing, "SetValue is expected, but missing, for #{ole_method_name}"
      end
    end
    
    # Gets a value by calling OLEMethodName.GetValue
    def get_value(ole_method_name, *params)
      obj = @ole_object.send(ole_method_name.to_s.camelize.gsub(/Id/, 'ID'), *params)
      if detect_ole_method?(obj, "GetValue")
        if ole_method_name.to_s =~ /date/i || ole_method_name.to_s =~ /time/i 
          Time.parse(obj.GetValue)
        else
          obj.GetValue
        end
      else
        return(obj.kind_of?(WIN32OLE) ? self.class.new(obj) : obj)
      end
    end

    # Sets up an array to return if the return of OLEMethodName appears
    # to be a list structure.
    def setup_array(ole_method_name)
      list = @ole_object.send(ole_method_name)
      ary = []
      0.upto(list.Count - 1) do |i|
        ary << self.class.new(list.GetAt(i))
      end
      return ary
    end
    
    # Creates a QBFC::Base inherited object if the return of
    # OLEMethodName appears to be a reference to such an object.
    def create_ref(symbol, is_entity = false, *options)
      ref_ole_name = symbol.to_s.camelize + (is_entity ? "EntityRef" : "Ref")
      ref_ole_object = @ole_object.send(ref_ole_name)
      if ref_ole_object
        is_entity ?
          QBFC::Entity.find_by_list_id(@sess, ref_ole_object.ListID.GetValue(), *options) :
          QBFC::const_get("#{symbol.to_s.camelize}").find_by_list_id(@sess, ref_ole_object.ListID.GetValue(), *options)
      else
        return nil
      end
    end
    
    # Check if the obj has an ole_method matching the symbol.
    def detect_ole_method?(obj, symbol)
      obj && obj.respond_to?(:ole_methods) && obj.ole_methods.detect{|m| m.to_s == symbol.to_s}
    end
  end
end