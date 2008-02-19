module QBFC
  
  # Generated Item Types (Inherit from List)
  ITEM_TYPES = %w{ItemService ItemNonInventory ItemOtherCharge ItemInventory ItemInventoryAssembly ItemFixedAsset
      ItemSubtotal ItemDiscount ItemPayment ItemSalesTax ItemSalesTaxGroup ItemGroup}
  
  # Generate Item subclasses
  # NB: All Items are Modifiable
  generate(ITEM_TYPES, Item, {Modifiable => ITEM_TYPES})
  
end