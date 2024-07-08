class ItemList {
  final int listId;
  final String userName;
  final int? customerId;
  final DateTime dateCreated;
  final String listName;

  ItemList({
    required this.listId,
    required this.userName,
    required this.customerId,
    required this.dateCreated,
    required this.listName,
  });

  factory ItemList.fromJson(Map<String, dynamic> json) {
    return ItemList(
      listId: json['ListId'],
      userName: json['UserName'],
      customerId: json['CustomerId'],
      dateCreated: DateTime.parse(json['DateCreated']),
      listName: json['ListName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ListId': listId,
      'UserName': userName,
      'CustomerId': customerId,
      'DateCreated': dateCreated.toIso8601String(),
      'ListName': listName,
    };
  }
}
