module QBFC
  class Terms < List
    is_base_class
  end
end

# Require subclass files
Dir[File.dirname(__FILE__) + '/terms/*.rb'].each do |file|
  require file
end
