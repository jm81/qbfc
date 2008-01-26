module QBFC
  class OLEWrapper
    def initialize(ole_object)
      ole_object = WIN32OLE.new(ole_object) if ole_object.kind_of?(String)
      @ole_object = ole_object
    end
    
    def ole_methods
      @ole_object.ole_methods
    end
    
    def [](idx)
      if idx.kind_of? Integer
        self.class.new(@ole_object.GetAt(idx))
      else
        @ole_object[idx]
      end
    end
  
    def qbfc_method_missing(sess, symbol, *params)
      @sess = sess
      method_missing(symbol, *params)
    end
  
    def method_missing(symbol, *params)
      if (('a'..'z') === symbol.to_s[0].chr)
        lower_case_method_missing(symbol, *params)
      else
        resp = @ole_object.send(symbol, *params)
        resp.kind_of?(WIN32OLE) ?
          self.class.new(resp) :
          resp
      end
    end
    
    private

    def lower_case_method_missing(symbol, *params)
      if '=' == symbol.to_s[-1].chr
        set_value(symbol.to_s[0..-2], *params)
      elsif detect_ole_method?(@ole_object, symbol.to_s.camelize)
        get_value(symbol, *params)
      elsif detect_ole_method?(@ole_object, symbol.to_s.singularize.camelize + "RetList")
        setup_array(symbol.to_s.singularize.camelize + "RetList")
      elsif detect_ole_method?(@ole_object, symbol.to_s.camelize + "EntityRef")
        create_ref(symbol, true)
      elsif detect_ole_method?(@ole_object, symbol.to_s.camelize + "Ref")
        create_ref(symbol)
      else
        raise NoMethodError, symbol
      end 
    end
    
    def set_value(ole_method_name, *params)
      obj = @ole_object.send(ole_method_name.to_s.camelize)

      if detect_ole_method?(obj, "SetValue")
        obj.SetValue(*params)
      else
        raise SetValueMissing, "SetValue is expected, but missing, for #{symbol.to_s.camelize}"
      end
    end
    
    def setup_array(ole_method_name)
      list = @ole_object.send(ole_method_name)
      ary = []
      0.upto(list.Count - 1) do |i|
        ary << self.class.new(list.GetAt(i))
      end
      return ary
    end
    
    def get_value(ole_method_name, *params)
      obj = @ole_object.send(ole_method_name.to_s.camelize, *params)

      if detect_ole_method?(obj, "GetValue")
        if ole_method_name.to_s =~ /date/i || ole_method_name.to_s =~ /time/i 
          Time.parse(obj.GetValue)
        else
          obj.GetValue
        end
      else
        obj.kind_of?(WIN32OLE) ? self.class.new(obj) : obj
      end
    end
    
    def create_ref(symbol, is_entity = false)
      ref_ole_name = symbol.to_s.camelize + (is_entity ? "EntityRef" : "Ref")
      ref_ole_object = @ole_object.send(ref_ole_name)
      if ref_ole_object
        is_entity ?
          QBFC::Entity.find_by_list_id(@sess, ref_ole_object.ListID.GetValue()) :
          QBFC::const_get("#{symbol.to_s.camelize}").find_by_list_id(@sess, ref_ole_object.ListID.GetValue())
      else
        return nil
      end
    end
    
    def detect_ole_method?(obj, symbol)
      obj && obj.respond_to?(:ole_methods) && obj.ole_methods.detect{|m| m.to_s == symbol.to_s}
    end
  end
end