module QBFC
  # Generated Entity Types (Inherit from List)
  ENTITY_TYPES = %w{Customer Employee OtherName Vendor}
  
  # Generate Entity subclasses
  # NB: All Entities are Modifiable
  generate(ENTITY_TYPES, Entity, {Modifiable => ENTITY_TYPES})
end