class Payment {
  final int orderNumber;
  final int lineNumber;
  final DateTime datePaid;
  final double amountPaid;
  final String comments;
  final int branchID;
  final String howPaid;

  Payment({
    required this.orderNumber,
    required this.lineNumber,
    required this.datePaid,
    required this.amountPaid,
    required this.comments,
    required this.branchID,
    required this.howPaid,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      orderNumber: json['OrderNumber'],
      lineNumber: json['LineNumber'],
      datePaid: DateTime.parse(json['DatePaid']),
      amountPaid: json['AmountPaid'].toDouble(),
      comments: json['Comments'],
      branchID: json['BranchID'],
      howPaid: json['HowPaid'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OrderNumber': orderNumber,
      'LineNumber': lineNumber,
      'DatePaid': datePaid.toIso8601String(),
      'AmountPaid': amountPaid,
      'Comments': comments,
      'BranchID': branchID,
      'HowPaid': howPaid,
    };
  }
}
