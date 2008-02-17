module QBFC

  # An Element is a Transaction or a List; that is any QuickBooks objects that can
  # be created, edited (possibly), deleted and read. Contrast to a Report or Info
  # which are read-only.
  # 
  # Inheritance from Element implies a set of shared methods, such as find, but the
  # only shared implementation defined here is #custom, for getting custom field information.
  class Element < Base
  
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
    
  end
end