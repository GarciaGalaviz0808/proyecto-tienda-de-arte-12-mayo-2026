import 'package:cloud_firestore/cloud_firestore.dart';

class OrderItemModel {
  final String prodId;
  final String name;
  final double priceUnit;
  final String brand;
  final String imageUrl;
  final int quantity;

  OrderItemModel({
    required this.prodId,
    required this.name,
    required this.priceUnit,
    required this.brand,
    required this.imageUrl,
    required this.quantity,
  });

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      prodId: map['prodId'] ?? '',
      name: map['name'] ?? '',
      priceUnit: (map['priceUnit'] as num?)?.toDouble() ?? 0.0,
      brand: map['brand'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prodId': prodId,
      'name': name,
      'priceUnit': priceUnit,
      'brand': brand,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }
}

class OrderModel {
  final String orderId;
  final String userId;
  final List<OrderItemModel> items;
  final double subtotal;
  final String? couponCode;
  final double discountAmount;
  final double shippingCost;
  final double total;
  final int loyaltyPointsEarned;
  final String status; // pending | processing | shipped | delivered | cancelled
  final String paymentMethod; // cash | card | paypal
  final Map<String, String> shippingAddress;
  final DateTime createdAt;
  final DateTime updatedAt;

  OrderModel({
    required this.orderId,
    required this.userId,
    required this.items,
    required this.subtotal,
    this.couponCode,
    required this.discountAmount,
    required this.shippingCost,
    required this.total,
    required this.loyaltyPointsEarned,
    required this.status,
    required this.paymentMethod,
    required this.shippingAddress,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawItems = data['items'] as List<dynamic>? ?? [];
    final discountApplied = data['discountApplied'] as Map<String, dynamic>? ?? {};
    final rawAddress = data['shippingAddress'] as Map<String, dynamic>? ?? {};

    return OrderModel(
      orderId: doc.id,
      userId: data['userId'] ?? '',
      items: rawItems.map((item) => OrderItemModel.fromMap(item as Map<String, dynamic>)).toList(),
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      couponCode: discountApplied['couponCode'],
      discountAmount: (discountApplied['amount'] as num?)?.toDouble() ?? 0.0,
      shippingCost: (data['shippingCost'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      loyaltyPointsEarned: data['loyaltyPointsEarned'] ?? 0,
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? 'cash',
      shippingAddress: Map<String, String>.from(rawAddress),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'subtotal': subtotal,
      'discountApplied': {
        'couponCode': couponCode,
        'amount': discountAmount,
      },
      'shippingCost': shippingCost,
      'total': total,
      'loyaltyPointsEarned': loyaltyPointsEarned,
      'status': status,
      'paymentMethod': paymentMethod,
      'shippingAddress': shippingAddress,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
