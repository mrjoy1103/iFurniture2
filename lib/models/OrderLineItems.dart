class OrderLineItems {
  final int orderNumber;
  final int lineNumber;
  final int itemNumber;
  final double quantity;
  final double price;
  final String model;
  final double cost;
  final bool taxable;
  final bool processed;
  final String description;
  final String itemNote;
  final String category;

  OrderLineItems({
    required this.orderNumber,
    required this.lineNumber,
    required this.itemNumber,
    required this.quantity,
    required this.price,
    required this.model,
    required this.cost,
    required this.taxable,
    required this.processed,
    required this.description,
    required this.itemNote,
    required this.category,
  });

  factory OrderLineItems.fromJson(Map<String, dynamic> json) {
    return OrderLineItems(
      orderNumber: json['OrderNumber'],
      lineNumber: json['LineNumber'],
      itemNumber: json['ItemNumber'],
      quantity: json['Quantity'].toDouble(),
      price: json['Price'].toDouble(),
      model: json['Model'],
      cost: json['Cost'].toDouble(),
      taxable: json['Taxable'],
      processed: json['Processed'],
      description: json['Description'],
      itemNote: json['ItemNote'],
      category: json['Category'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OrderNumber': orderNumber,
      'LineNumber': lineNumber,
      'ItemNumber': itemNumber,
      'Quantity': quantity,
      'Price': price,
      'Model': model,
      'Cost': cost,
      'Taxable': taxable,
      'Processed': processed,
      'Description': description,
      'ItemNote': itemNote,
      'Category': category,
    };
  }
}
