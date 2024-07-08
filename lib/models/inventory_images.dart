class InventoryImages {
  final int itemNumber;
  final List<ItemImage> itemImage;

  InventoryImages({required this.itemNumber, required this.itemImage});

  factory InventoryImages.fromJson(Map<String, dynamic> json) {
    return InventoryImages(
      itemNumber: (json['ItemNumber'] is int)
          ? json['ItemNumber']
          : (json['ItemNumber'] as double).toInt(),
      itemImage: (json['itemImage'] as List<dynamic>?)
          ?.map((item) => ItemImage.fromJson(item))
          .toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ItemNumber': itemNumber,
      'itemImage': itemImage.map((item) => item.toJson()).toList(),
    };
  }
}

class ItemImage {
  final String imageBase64;
  final String fileName;

  ItemImage({required this.imageBase64, required this.fileName});

  factory ItemImage.fromJson(Map<String, dynamic> json) {
    return ItemImage(
      imageBase64: json['imageBase64'] ?? '',
      fileName: json['fileName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'imageBase64': imageBase64,
      'fileName': fileName,
    };
  }
}

