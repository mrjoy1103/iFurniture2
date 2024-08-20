class OrderFilter {
  final DateTime? orderDate;
  final String textFilter;
  final String status;
  final bool? complete;

  OrderFilter({
    this.orderDate,
    required this.textFilter,
    required this.status,
    this.complete,
  });

  // Convert OrderFilter to JSON
  Map<String, dynamic> toJson() {
    return {
      'orderDate': orderDate?.toIso8601String(), // Handle nullable DateTime
      'textFilter': textFilter,
      'status': status,
      'complete': complete,
    };
  }

  // Factory constructor to create OrderFilter from JSON (if needed)
  factory OrderFilter.fromJson(Map<String, dynamic> json) {
    return OrderFilter(
      orderDate: json['orderDate'] != null ? DateTime.parse(json['orderDate']) : null,
      textFilter: json['textFilter'],
      status: json['status'],
      complete: json['complete'],
    );
  }
}
