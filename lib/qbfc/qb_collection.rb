module QBFC

  # A QBCollection object is used as an intermediate object when doing finds,
  # for example, in <tt>qb_session.customers.find(:all)</tt>, +customers+
  # returns a QBCollection instance which then is sent the find call.
  # The instance sends the find method on to the appropriate Class.
  # The reason for having this intermediate class is to be able to
  # pass a reference to the Session to the find method
  # (or other class method).
  # 
  # There's probably no reason to use this class directly.
  class QBCollection
    
    # +sess+ is a QBFC::Session object, +class_name+ is the name of
    # a class descended from QBFC::Base.
    def initialize(sess, class_name)
      @sess = sess
      @klass = QBFC::const_get(class_name)
    end
  
    # Send any missing methods to the class, along with the +Session+ object
    def method_missing(symbol, *params) #:nodoc:
      @klass.send(symbol, @sess, *params)
    end
  end
end