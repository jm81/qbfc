module QBFC
  # Entity objects are Customers, Employees, Vendors and OtherNames
  class Item < List
    is_base_class
  end
end

# Require subclass files
Dir[File.dirname(__FILE__) + '/items/*.rb'].each do |file|
  require file
end