# QBFC_CONST contains constants defined by QBFC6.QBSessionManager.
# For example:
# 
#   QBFC_CONST::DmToday # => 1 (for DateMacro)

module QBFC_CONST
end

WIN32OLE.const_load(WIN32OLE.new('QBFC6.QBSessionManager'), QBFC_CONST)
