module QBFC
  # QBClass objects represent QuickBooks SDK's <tt>Class</tt> objects.
  # As naming this Class <tt>Class</tt> would be impractical, it is
  # instead called QBClass. It is otherwise similar to the other List
  # classes.
  # 
  # From QBFC6 SDK docs:
  # 
  # Classes can be used to separate transactions into meaningful categories.
  # (For example, transactions could be classified according to department,
  # business location, or type of work.) In QuickBooks, class tracking is
  # off by default.
  class QBClass < List
    class << self
      
      # The QuickBooks SDK class is called 'Class'.
      # Calling this class QBClass avoids making ruby
      # very angry; the qb_name method ensures that calls
      # to QBFC use the correct name.
      def qb_name
        "Class"
      end
    end
  end
end
