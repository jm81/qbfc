module QBFC
  class Account < List
    include Modifiable
    
    class << self
      
      # Adds a SpecialAccount, per SDK documentation:
      # "An account normally created automatically as needed within the 
      # QuickBooks UI, or in the SDK via the SpecialAccountAdd request."
      # 
      # +account_type+ should be a constent, for example:
      # 
      #   Account.add_special(sess, QBFC_CONST::SatAccountsPayable)
      #   
      # See SDK docs for SpecialAccountAdd for more details.
      def add_special(sess, account_type)
        rq = QBFC::Request.new(sess, "SpecialAccountAdd")
        rq.special_account_type = account_type
        
        new(sess, rq.response)
      end
    end
  end
end
