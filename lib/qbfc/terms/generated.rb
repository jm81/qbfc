module QBFC
  
  # Generated Terms Types (Inherit from List)
  TERMS_TYPES = %w{DateDrivenTerms StandardTerms}
  
  # Generate Terms subclasses
  # NB: All Terms are Modifiable
  generate(TERMS_TYPES, Terms)
  
end