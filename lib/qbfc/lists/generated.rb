module QBFC

  # Generated List types that will inherit directly from QBFC::List
  LIST_TYPES = %w{Account BillingRate CustomerMsg CustomerType JobType  PaymentMethod
      PayrollItemNonWage PayrollItemWage PriceLevel SalesRep SalesTaxCode ShipMethod ToDo
      Vehicle VendorType}
  
  # Generated List types that do not accept Mod Requests
  LIST_NO_MOD_TYPES = %w{ BillingRate CustomerMsg CustomerType JobType PaymentMethod
      PayrollItemWage SalesTaxCode ShipMethod ToDo VendorType}
  
  # Generate List subclasses
  generate(LIST_TYPES, List, {Modifiable => LIST_TYPES - LIST_NO_MOD_TYPES})
  
end