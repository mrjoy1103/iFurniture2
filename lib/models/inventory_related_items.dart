class InventoryRelatedItems {
  final int id;
  final double itemNumber;
  final double relatedItem;
  final double sortOrder;

  InventoryRelatedItems({
    required this.id,
    required this.itemNumber,
    required this.relatedItem,
    required this.sortOrder,
  });

  factory InventoryRelatedItems.fromJson(Map<String, dynamic> json) {
    return InventoryRelatedItems(
      id: json['ID'] ?? 0,
      itemNumber: json['ItemNumber']?.toDouble() ?? 0.0,
      relatedItem: json['RelatedItem']?.toDouble() ?? 0.0,
      sortOrder: json['SortOrder']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ItemNumber': itemNumber,
      'RelatedItem': relatedItem,
      'SortOrder': sortOrder,
    };
  }
}
