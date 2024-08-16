
class ListedItem {
  final int listId;
  final int itemNumber;
  int? quantity;
  final double price;

  ListedItem({
    required this.listId,
    required this.itemNumber,
    this.quantity,
    required this.price,
  });

  factory ListedItem.fromJson(Map<String, dynamic> json) {
    return ListedItem(
      listId: json['ListId'],
      itemNumber: json['ItemNumber'],
      quantity: json['Quantity'],
      price: json['Price'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ListId': listId,
      'ItemNumber': itemNumber,
      'Quantity': quantity,
      'Price': price,
    };
  }
}
