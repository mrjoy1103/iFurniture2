class Supplier {
  final int supplierNumber;
  final String supplierName;

  Supplier({
    required this.supplierNumber,
    required this.supplierName,
  });

  factory Supplier.fromJson(Map<String, dynamic> json) {
    return Supplier(
      supplierNumber: json['SupplierNumber'] ?? 0,
      supplierName: json['SupplierName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'SupplierNumber': supplierNumber,
      'SupplierName': supplierName,
    };
  }
}
