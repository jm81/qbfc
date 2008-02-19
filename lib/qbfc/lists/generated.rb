module QBFC

  # Generated List types that will inherit directly from QBFC::List
  LIST_TYPES = %w{Account BillingRate QBClass CustomerMsg CustomerType JobType  PaymentMethod
      PayrollItemNonWage PayrollItemWage PriceLevel SalesRep SalesTaxCode ShipMethod ToDo
      Vehicle VendorType}
  
   # Generated Terms Types (Inherit from List)
  TERMS_TYPES = %w{DateDrivenTerms StandardTerms}
             
  # Generated List types that do not accept Mod Requests
  LIST_NO_MOD_TYPES = %w{ BillingRate CustomerMsg CustomerType DateDrivenTerms JobType PaymentMethod
      PayrollItemWage SalesTaxCode ShipMethod StandardTerms ToDo VendorType QBClass}

  ALL_LIST_TYPES = LIST_TYPES + TERMS_TYPES
  
  # Generate List subclasses
  generate(ALL_LIST_TYPES, List, {Modifiable => ALL_LIST_TYPES - LIST_NO_MOD_TYPES})
  
end