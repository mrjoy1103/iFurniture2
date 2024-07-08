class BranchInventory {
  final int itemNumber;
  final int branchID;
  final double onOrder;
  final double spclOrder;
  final double inStock;
  final double onHold;
  final double available;
  final String branchName;
  final double saleTax;

  BranchInventory({
    required this.itemNumber,
    required this.branchID,
    required this.onOrder,
    required this.spclOrder,
    required this.inStock,
    required this.onHold,
    required this.available,
    required this.branchName,
    required this.saleTax,
  });

  factory BranchInventory.fromJson(Map<String, dynamic> json) {
    return BranchInventory(
      itemNumber: json['Item_Number'] ?? 0,
      branchID: json['BranchID'] ?? 0,
      onOrder: json['OnOrder']?.toDouble() ?? 0.0,
      spclOrder: json['SpclOrder']?.toDouble() ?? 0.0,
      inStock: json['InStock']?.toDouble() ?? 0.0,
      onHold: json['OnHold']?.toDouble() ?? 0.0,
      available: json['Available']?.toDouble() ?? 0.0,
      branchName: json['branchName'] ?? '',
      saleTax: json['SaleTax']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Item_Number': itemNumber,
      'BranchID': branchID,
      'OnOrder': onOrder,
      'SpclOrder': spclOrder,
      'InStock': inStock,
      'OnHold': onHold,
      'Available': available,
      'branchName': branchName,
      'SaleTax': saleTax,
    };
  }
}
