module QBFC

  # Generated Info types
  INFO_TYPES = %w{Company CompanyActivity Host Preferences}
  
  # Generate List subclasses
  generate(INFO_TYPES, Info)
  
end