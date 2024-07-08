class SelectedItemList {
  final int listID;
  final List<int> itemNumber;

  SelectedItemList({
    required this.listID,
    required this.itemNumber,
  });

  factory SelectedItemList.fromJson(Map<String, dynamic> json) {
    return SelectedItemList(
      listID: json['ListID'],
      itemNumber: List<int>.from(json['itemNumber']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ListID': listID,
      'itemNumber': itemNumber,
    };
  }
}
