module QBFC

  # Generated List types that will inherit directly from QBFC::List
  LIST_TYPES = %w{ BillingRate CustomerMsg CustomerType JobType  PaymentMethod
      PayrollItemNonWage PayrollItemWage PriceLevel SalesRep SalesTaxCode
      ShipMethod ToDo Vehicle VendorType}
  
  # Generated List types that do accept Mod Requests
  # (most direct subclasses of List do not)
  LIST_MOD_TYPES = %w{ PriceLevel SalesRep Vehicle }
  
  # Generate List subclasses
  generate(LIST_TYPES, List, {Modifiable => LIST_MOD_TYPES})
  
end