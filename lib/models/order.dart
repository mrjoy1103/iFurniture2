import 'package:fw_demo/models/Payment.dart'; // Assuming these models are created
import 'package:fw_demo/models/OrderLineItems.dart';

class Order {
  final int orderNumber;
  final int branchID;
 // final String type;
  final String status;
 // final int customerNumber;
  final DateTime date;
  final String salesPerson;
 // final int customerNumberShipped;
 // final String shipToOther;
 // final bool useOtherShipTo;
  final double subTotal;
//  final double delivery;
 // final double tax;
 // final String orderNotes;
 // final int priceLevel;
 // final String referredBy;
 // final bool complete;
 // final String firstName;
 // final String lastName;
 // final double? taxPercent;
  final double? discount;
 // final bool deliveryTaxable;
 // final List<Payment> payment;
 // final List<OrderLineItems> orderLineItems;
  final DateTime? completeDate;

  Order({
    required this.orderNumber,
    required this.branchID,
   // required this.type,
    required this.status,
  //  required this.customerNumber,
    required this.date,
    required this.salesPerson,
  //  required this.customerNumberShipped,
  //  required this.shipToOther,
  //  required this.useOtherShipTo,
    required this.subTotal,
 //   required this.delivery,
  //  required this.tax,
 //   required this.orderNotes,
  //  required this.priceLevel,
  //  required this.referredBy,
  //  required this.complete,
 //   required this.firstName,
 //   required this.lastName,
  //  this.taxPercent,
    this.discount,
 //   required this.deliveryTaxable,
  //  required this.payment,
   // required this.orderLineItems,
    this.completeDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderNumber: json['OrderNumber'],
      branchID: json['BranchID'],
      //type: json['Type'],
      status: json['Status'],
     // customerNumber: json['CustomerNumber'],
      date: DateTime.parse(json['Date']),
      salesPerson: json['SalesPerson'],
      //customerNumberShipped: json['CustomerNumberShipped'],
      //shipToOther: json['ShipToOther'],
      //useOtherShipTo: json['UseOtherShipTo'],
      subTotal: json['SubTotal'].toDouble(),
     // delivery: json['Delivery'].toDouble(),
      //tax: json['Tax'].toDouble(),
      //orderNotes: json['OrderNotes'],
     // priceLevel: json['PriceLevel'],
     // referredBy: json['Referred_By'],
     // complete: json['Complete'],
     // firstName: json['FirstName'],
     // lastName: json['LastName'],
    //  taxPercent: json['TaxPercent']?.toDouble(),
      discount: json['Discount']?.toDouble(),
     // deliveryTaxable: json['DeliveryTaxable'],
    //  payment: (json['Payment'] as List).map((i) => Payment.fromJson(i)).toList(),
     // orderLineItems: (json['OrderLineItems'] as List)
         // .map((i) => OrderLineItems.fromJson(i))
         // .toList(),
      completeDate: json['Complete_Date'] != null
          ? DateTime.parse(json['Complete_Date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'OrderNumber': orderNumber,
      'BranchID': branchID,
      //'Type': type,
      'Status': status,
     // 'CustomerNumber': customerNumber,
      'Date': date.toIso8601String(),
      'SalesPerson': salesPerson,
     // 'CustomerNumberShipped': customerNumberShipped,
     // 'ShipToOther': shipToOther,
     // 'UseOtherShipTo': useOtherShipTo,
      'SubTotal': subTotal,
     // 'Delivery': delivery,
     // 'Tax': tax,
     // 'OrderNotes': orderNotes,
     // 'PriceLevel': priceLevel,
     // 'Referred_By': referredBy,
     // 'Complete': complete,
    //  'FirstName': firstName,
    //  'LastName': lastName,
    //  'TaxPercent': taxPercent,
      'Discount': discount,
    //  'DeliveryTaxable': deliveryTaxable,
   //   'Payment': payment.map((i) => i.toJson()).toList(),
     // 'OrderLineItems': orderLineItems.map((i) => i.toJson()).toList(),
      'Complete_Date': completeDate?.toIso8601String(),
    };
  }
}
