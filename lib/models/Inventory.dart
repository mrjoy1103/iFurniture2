import 'branch_inventory.dart';
import 'inventory_related_items.dart';
import 'supplier.dart';
import 'collection.dart';

class Inventory {
  final int itemNumber;
  final String category;
  final double? cost;
  final String coverfinish;
  final double? cube;
  final String dimensions;
  final bool discontinued;
  final bool onSale;
  final bool taxable;
  final String description;
  final String longDescription;
  final String model;
  final double? retail;
  final String style;
  final String subCategory;
  final String upc;
  final String pictureFileName;
  final double discountPercentage;
  final double? discountAmount;
  final double freightPercentage;
  final double? freightAmount;
  final bool set;
  final Supplier supplier;
  final Collection collection;
  final List<InventoryRelatedItems> relatedItems;
  final List<BranchInventory> branchInventory;
  final double? aCost;

  Inventory({
    required this.itemNumber,
    required this.category,
    required this.cost,
    required this.coverfinish,
    required this.cube,
    required this.dimensions,
    required this.discontinued,
    required this.onSale,
    required this.taxable,
    required this.description,
    required this.longDescription,
    required this.model,
    required this.retail,
    required this.style,
    required this.subCategory,
    required this.upc,
    required this.pictureFileName,
    required this.discountPercentage,
    required this.discountAmount,
    required this.freightPercentage,
    required this.freightAmount,
    required this.set,
    required this.supplier,
    required this.collection,
    required this.relatedItems,
    required this.branchInventory,
    required this.aCost,
  });

  factory Inventory.fromJson(Map<String, dynamic> json) {
    try {
      return Inventory(
        itemNumber: json['ItemNumber'] ?? 0,
        category: json['Category'] ?? '',
        cost: json['Cost']?.toDouble(),
        coverfinish: json['Coverfinish'] ?? '',
        cube: json['Cube']?.toDouble(),
        dimensions: json['Dimensions'] ?? '',
        discontinued: json['Discontinued'] ?? false,
        onSale: json['OnSale'] ?? false,
        taxable: json['Taxable'] ?? false,
        description: json['Description'] ?? '',
        longDescription: json['Long_Description'] ?? '',
        model: json['Model'] ?? '',
        retail: json['Retail']?.toDouble(),
        style: json['Style'] ?? '',
        subCategory: json['SubCategory'] ?? '',
        upc: json['UPC'] ?? '',
        pictureFileName: json['Picture_FileName'] ?? '',
        discountPercentage: json['DiscountPercentage']?.toDouble() ?? 0.0,
        discountAmount: json['DiscountAmount']?.toDouble(),
        freightPercentage: json['FreightPercentage']?.toDouble() ?? 0.0,
        freightAmount: json['FreightAmount']?.toDouble(),
        set: json['Set'] ?? false,
        supplier: Supplier.fromJson(json['supplier'] ?? {}),
        collection: Collection.fromJson(json['collection'] ?? {}),
        relatedItems: (json['relatedItems'] as List<dynamic>?)
            ?.map((item) => InventoryRelatedItems.fromJson(item))
            .toList() ?? [],
        branchInventory: (json['branchInventory'] as List<dynamic>?)
            ?.map((item) => BranchInventory.fromJson(item))
            .toList() ?? [],
        aCost: json['ACost']?.toDouble(),
      );
    } catch (e) {
      print('Error parsing Inventory: $e');
      throw e;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemNumber': itemNumber,
      'Category': category,
      'Cost': cost,
      'Coverfinish': coverfinish,
      'Cube': cube,
      'Dimensions': dimensions,
      'Discontinued': discontinued,
      'OnSale': onSale,
      'Taxable': taxable,
      'Description': description,
      'Long_Description': longDescription,
      'Model': model,
      'Retail': retail,
      'Style': style,
      'SubCategory': subCategory,
      'UPC': upc,
      'Picture_FileName': pictureFileName,
      'DiscountPercentage': discountPercentage,
      'DiscountAmount': discountAmount,
      'FreightPercentage': freightPercentage,
      'FreightAmount': freightAmount,
      'Set': set,
      'supplier': supplier.toJson(),
      'collection': collection.toJson(),
      'relatedItems': relatedItems.map((item) => item.toJson()).toList(),
      'branchInventory': branchInventory.map((item) => item.toJson()).toList(),
      'ACost': aCost,
    };
  }
}
