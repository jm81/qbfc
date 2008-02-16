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
  # 
  # Now, the fun (and +really+ hackish) part. In many cases within the QBFC
  # library, the wrapper is actually wrapping two WIN32OLE objects, the additional
  # being a 'setter' object. This object is used when creating a ModRequest. In
  # such cases, a method ending in '=' is always sent to both the primary and the
  # setter objects. To facilitate this, traversing child ole_objects also
  # traverses the child setter objects.
  class OLEWrapper
    attr_reader :ole_object
    attr_accessor :setter
  
    # Set up wrapped object, by passing a WIN32OLE object
    # (or a String with the name of a WIN32OLE server)
    # Optionally, pass a +setter+ WIN32OLE object.
    def initialize(ole_object, setter = nil)
      ole_object = WIN32OLE.new(ole_object) if ole_object.kind_of?(String)
      @ole_object = ole_object
      @setter = setter
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
      elsif symbol.to_s =~ /\A(\w+)_(full_name|id)\Z/ && ref_name($1)
        get_ref_name_or_id(ref_name($1), $2)
      elsif detect_ole_method?(@ole_object, ole_sym(symbol))
        get_value(symbol, *params)
      elsif detect_ole_method?(@ole_object, (s = symbol.to_s.singularize.camelize + "RetList"))
        setup_array(s)
      elsif detect_ole_method?(@ole_object, (s = "OR" + symbol.to_s.singularize.camelize + "RetList"))
        setup_array(s, true)
      elsif ref_name(symbol)
        create_ref(ref_name(symbol), *params)
      else
        raise NoMethodError, symbol.to_s
      end 
    end
    
    # Sets a value by calling OLEMethodName.SetValue(*params)
    def set_value(ole_method_name, *params)
      ole_method_name = ole_sym(ole_method_name)
      obj = @ole_object.send(ole_method_name)

      if detect_ole_method?(obj, "SetValue")
        obj.SetValue(*params)
        if @setter && detect_ole_method?(@setter, ole_method_name)
          @setter.send(ole_method_name).SetValue(*params)
        end
      else
        raise SetValueMissing, "SetValue is expected, but missing, for #{ole_method_name}"
      end
    end
    
    # Gets a value by calling OLEMethodName.GetValue
    def get_value(ole_method_name, *params)
      ole_method_name = ole_sym(ole_method_name)
      obj = @ole_object.send(ole_method_name, *params)
      if detect_ole_method?(obj, "GetValue")
        if ole_method_name =~ /date/i || ole_method_name.to_s =~ /time/i 
          Time.parse(obj.GetValue)
        else
          obj.GetValue
        end
      else
        if obj.kind_of?(WIN32OLE)
          if @setter && detect_ole_method?(@setter, ole_method_name)
            self.class.new(obj, @setter.send(ole_method_name, *params))
          else
            self.class.new(obj)
          end
        else
          obj
        end
      end
    end

    # Sets up an array to return if the return of OLEMethodName appears
    # to be a list structure.
    # <tt>is_OR_list</tt> indicates the list is an OR*RetList which
    # is structured differently.
    def setup_array(ole_method_name, is_OR_list = false)
      list = @ole_object.send(ole_method_name)
      ary = []
      0.upto(list.Count - 1) do |i|
        if is_OR_list
          ary << self.class.new(list.GetAt(i)).send(ole_method_name.match(/\AOR(.*)List\Z/)[1])
        else
          ary << self.class.new(list.GetAt(i))
        end
      end
      return ary
    end
    
    def ref_name(symbol)
      if detect_ole_method?(@ole_object, symbol.to_s.camelize + "Ref")
        symbol.to_s.camelize + "Ref"
      elsif detect_ole_method?(@ole_object, symbol.to_s.camelize + "EntityRef")
        symbol.to_s.camelize + "EntityRef"
      else
        nil
      end
    end
    
    # Creates a QBFC::Base inherited object if the return of
    # OLEMethodName appears to be a reference to such an object.
    def create_ref(ref_ole_name, *options)
      ref_ole_object = @ole_object.send(ref_ole_name)
      if ref_ole_object
        ref_ole_name =~ /EntityRef/ ?
          QBFC::Entity.find_by_list_id(@sess, ref_ole_object.ListID.GetValue(), *options) :
          QBFC::const_get(ref_ole_name.gsub(/Ref/,"")).find_by_list_id(@sess, ref_ole_object.ListID.GetValue(), *options)
      else
        return nil
      end
    end
    
    def get_ref_name_or_id(symbol, field)
      field = (field == "id" ? "ListID" : "FullName")
      @ole_object.send(symbol).send(field).GetValue()
    end
    
    # Check if the obj has an ole_method matching the symbol.
    def detect_ole_method?(obj, symbol)
      obj && obj.respond_to?(:ole_methods) && obj.ole_methods.detect{|m| m.to_s == symbol.to_s}
    end
    
    # Helper method to convert 'Ruby-ish' method name to WIN32OLE method name
    def ole_sym(symbol)
      symbol.to_s.camelize.gsub(/Id/, 'ID')
    end
  end
end