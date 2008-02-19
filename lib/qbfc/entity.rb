module QBFC
  # Entity objects are Customers, Employees, Vendors and OtherNames
  class Entity < List
    is_base_class
  end
end

# Require subclass files
Dir[File.dirname(__FILE__) + '/entities/*.rb'].each do |file|
  require file
end
