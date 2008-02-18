module QBFC
  # List objects are those with names, such as Accounts, Entities, and Items.
  # 
  # Note on the name: it doesn't make sense since a List is actually a single object,
  # but it fits with the SDK's naming scheme, and I couldn't think of a better one.
  class List < Element
    is_base_class
    
    # Alias of ListID for this record. This is a unique within each type of List.
    def id
      @ole.list_id
    end
    
    # Delete this List record.
    def delete
      req = QBFC::Request.new(@sess, "ListDel")
      req.list_del_type = QBFC_CONST::const_get("Ldt#{qb_name}")
      req.list_id = id
      req.submit
      return true
    end    
  end
end