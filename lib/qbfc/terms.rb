module QBFC
  class Terms < List
    is_base_class
  end
end

# Require subclass files
Dir.new(File.dirname(__FILE__) + '/terms').each do |file|
  require('qbfc/terms/' + File.basename(file)) if File.extname(file) == ".rb"
end
