module QBFC
  class Item < List
    is_base_class
    
    class << self
      
      # Adds a SpecialItem.
      # 
      # +item_type+ should be a constent, for example:
      # 
      #   Account.add_special(sess, QBFC_CONST::SitFinanceCharge)
      #   
      # See SDK docs for SpecialItemAdd for more details.
      def add_special(sess, item_type)
        rq = QBFC::Request.new(sess, "SpecialItemAdd")
        rq.special_item_type = item_type
        
        # Insofar as I never actually plan to use this method, just return
        # response.
        return rq.response
      end
    end
  end
end

# Require subclass files
Dir[File.dirname(__FILE__) + '/items/*.rb'].each do |file|
  require file
end
