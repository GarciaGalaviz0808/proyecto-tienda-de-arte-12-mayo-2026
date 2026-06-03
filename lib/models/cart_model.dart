import 'package:cloud_firestore/cloud_firestore.dart';

class CartItemModel {
  final String prodId;
  final String nameSnapshot;
  final double priceSnapshot;
  final String brandSnapshot;
  final String imageUrl;
  final int quantity;

  CartItemModel({
    required this.prodId,
    required this.nameSnapshot,
    required this.priceSnapshot,
    required this.brandSnapshot,
    required this.imageUrl,
    required this.quantity,
  });

  factory CartItemModel.fromMap(Map<String, dynamic> map) {
    return CartItemModel(
      prodId: map['prodId'] ?? '',
      nameSnapshot: map['nameSnapshot'] ?? '',
      priceSnapshot: (map['priceSnapshot'] as num?)?.toDouble() ?? 0.0,
      brandSnapshot: map['brandSnapshot'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      quantity: map['quantity'] ?? 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'prodId': prodId,
      'nameSnapshot': nameSnapshot,
      'priceSnapshot': priceSnapshot,
      'brandSnapshot': brandSnapshot,
      'imageUrl': imageUrl,
      'quantity': quantity,
    };
  }

  CartItemModel copyWith({
    int? quantity,
  }) {
    return CartItemModel(
      prodId: prodId,
      nameSnapshot: nameSnapshot,
      priceSnapshot: priceSnapshot,
      brandSnapshot: brandSnapshot,
      imageUrl: imageUrl,
      quantity: quantity ?? this.quantity,
    );
  }
}

class CartModel {
  final String cartId;
  final String userId;
  final List<CartItemModel> items;
  final String? appliedCoupon;
  final double discountAmount;
  final double total;
  final DateTime updatedAt;

  CartModel({
    required this.cartId,
    required this.userId,
    required this.items,
    this.appliedCoupon,
    required this.discountAmount,
    required this.total,
    required this.updatedAt,
  });

  double get subtotal => items.fold(0.0, (sum, item) => sum + (item.priceSnapshot * item.quantity));

  factory CartModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawItems = data['items'] as List<dynamic>? ?? [];
    return CartModel(
      cartId: doc.id,
      userId: data['userId'] ?? '',
      items: rawItems.map((item) => CartItemModel.fromMap(item as Map<String, dynamic>)).toList(),
      appliedCoupon: data['appliedCoupon'],
      discountAmount: (data['discountAmount'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'items': items.map((item) => item.toMap()).toList(),
      'appliedCoupon': appliedCoupon,
      'discountAmount': discountAmount,
      'total': total,
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory CartModel.empty(String userId) {
    return CartModel(
      cartId: userId,
      userId: userId,
      items: [],
      appliedCoupon: null,
      discountAmount: 0.0,
      total: 0.0,
      updatedAt: DateTime.now(),
    );
  }
}
