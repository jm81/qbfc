module QBFC
  # Entity objects are Customers, Employees, Vendors and OtherNames
  class Entity < List
    is_base_class
  end
end

# Require subclass files
Dir.new(File.dirname(__FILE__) + '/entities').each do |file|
  require('qbfc/entities/' + File.basename(file)) if File.extname(file) == ".rb"
end
