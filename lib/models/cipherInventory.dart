class CipherInventory {
  final int id;
  final int itemNumber;
  final int qty;
  final String cipherDate;
  final DateTime dateTime;
  final String ipAddress;
  final int application;
  final String upc;
  final String supplier;
  final String description;
  final double price;
  final String poNumber;
  final double? lineNumber;
  final String userName;
  final String serialNumber;

  CipherInventory({
    required this.id,
    required this.itemNumber,
    required this.qty,
    required this.cipherDate,
    required this.dateTime,
    required this.ipAddress,
    required this.application,
    required this.upc,
    required this.supplier,
    required this.description,
    required this.price,
    required this.poNumber,
    this.lineNumber,
    required this.userName,
    required this.serialNumber,
  });

  factory CipherInventory.fromJson(Map<String, dynamic> json) {
    return CipherInventory(
      id: json['ID'],
      itemNumber: json['ItemNumber'],
      qty: json['Qty'],
      cipherDate: json['CipherDate'],
      dateTime: DateTime.parse(json['DateTime']),
      ipAddress: json['IPAddress'],
      application: json['Application'],
      upc: json['UPC'],
      supplier: json['Supplier'],
      description: json['Description'],
      price: json['Price'],
      poNumber: json['PONumber'],
      lineNumber: json['LineNumber'],
      userName: json['UserName'],
      serialNumber: json['SerialNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ID': id,
      'ItemNumber': itemNumber,
      'Qty': qty,
      'CipherDate': cipherDate,
      'DateTime': dateTime.toIso8601String(),
      'IPAddress': ipAddress,
      'Application': application,
      'UPC': upc,
      'Supplier': supplier,
      'Description': description,
      'Price': price,
      'PONumber': poNumber,
      'LineNumber': lineNumber,
      'UserName': userName,
      'SerialNumber': serialNumber,
    };
  }
}
