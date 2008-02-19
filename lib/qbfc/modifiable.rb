module QBFC
  module Modifiable

    # Extend initialize of including classes to set up a Mod Request
    # if the record is existing.
    def initialize(*args)
      super

      unless @new_record
        setup_mod_request
      end
    end

    # Setup a Mod Request for this object and attach it
    # to the ole object.
    def setup_mod_request
      @setter = QBFC::Request.new(@sess, "#{self.qb_name}Mod")
        
      if self.kind_of?(List)
        @setter.list_id = id
      else # Transaction
        @setter.txn_id = id
      end

      @setter.edit_sequence = @ole.edit_sequence
      @ole.setter = @setter.ole_object    
    end
    
    private :setup_mod_request
  end
end