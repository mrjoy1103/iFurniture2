class Collection {
  final int collectionID;
  final String collection;
  final String division;

  Collection({
    required this.collectionID,
    required this.collection,
    required this.division,
  });

  factory Collection.fromJson(Map<String, dynamic> json) {
    return Collection(
      collectionID: json['CollectionID'] ?? 0,
      collection: json['collection'] ?? '',
      division: json['Division'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'CollectionID': collectionID,
      'collection': collection,
      'Division': division,
    };
  }
}
