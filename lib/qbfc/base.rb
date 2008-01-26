class QBFC::Base
  class << self
    def find(sess, element_id)
      @id = element_id
    end
    
    def class_name
      self.name.split('::').last
    end
  end
  
  def initialize(sess, ole_object = nil)
    @sess = sess
    
    if ole_object.kind_of?(QBFC::OLEWrapper)
      @ole_object = ole_object
    elsif ole_object.kind_of?(WIN32OLE)
      @ole_object = QBFC::OLEWrapper.new(ole_object)
    else
      # TODO: Can I create a 'generic'?
    end
    
  end
  
  # If an entity has a Name field but not a FullName field,
  # use Name (which, by implication, is the FullName)
  def full_name
    @ole_object.ole_methods.detect{|m| m.to_s == "FullName"} ?
      @ole_object.FullName.GetValue :
      @ole_object.Name.GetValue
  end
  
  def ole_methods
    @ole_object.ole_methods
  end
  
  def method_missing(symbol, *params)
    @ole_object.qbfc_method_missing(@sess, symbol, *params)
  end
end

# Load extension modules
Dir[File.dirname(__FILE__) + "/element_extensions/*.rb"].each do |file|
  require(file)
end
