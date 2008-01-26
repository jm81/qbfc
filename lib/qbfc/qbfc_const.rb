# QBFC_CONST contains constants defined by QBFC6.QBSessionManager.
# For example:
# 
#   QBFC_CONST::DmToday # => 1 (for DateMacro)
#   
# The constants defined in the SDK documents all begin with a lower case letter.
# In contrast, WIN32OLE capitalizes the constants to follow Ruby naming conventions:
# 
#   QBFC_CONST::DmToday instead of QBFC_CONST::dmToday

module QBFC_CONST
end

WIN32OLE.const_load(WIN32OLE.new('QBFC6.QBSessionManager'), QBFC_CONST)
