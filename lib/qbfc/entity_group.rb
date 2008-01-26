class QBFC::EntityGroup
  def initialize(sess, class_name)
    @sess = sess
    @klass = QBFC::const_get(class_name)
  end

  def method_missing(symbol, *params)
    @klass.send(symbol, @sess, *params)
  end
end