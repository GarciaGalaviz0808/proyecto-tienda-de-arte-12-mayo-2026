import 'package:cloud_firestore/cloud_firestore.dart';

class CouponModel {
  final String code;
  final String type; // percentage | fixed
  final double value;
  final double minPurchase;
  final int maxUses;
  final int usedCount;
  final DateTime expiresAt;
  final List<String>? applicableCategories;
  final List<String>? applicableBrands;
  final bool isActive;
  final DateTime createdAt;

  CouponModel({
    required this.code,
    required this.type,
    required this.value,
    required this.minPurchase,
    required this.maxUses,
    required this.usedCount,
    required this.expiresAt,
    this.applicableCategories,
    this.applicableBrands,
    required this.isActive,
    required this.createdAt,
  });

  bool get isExpired => expiresAt.isBefore(DateTime.now());
  bool get isLimitReached => usedCount >= maxUses;

  factory CouponModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CouponModel(
      code: doc.id,
      type: data['type'] ?? 'percentage',
      value: (data['value'] as num?)?.toDouble() ?? 0.0,
      minPurchase: (data['minPurchase'] as num?)?.toDouble() ?? 0.0,
      maxUses: data['maxUses'] ?? 0,
      usedCount: data['usedCount'] ?? 0,
      expiresAt: (data['expiresAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      applicableCategories: data['applicableCategories'] != null
          ? List<String>.from(data['applicableCategories'])
          : null,
      applicableBrands: data['applicableBrands'] != null
          ? List<String>.from(data['applicableBrands'])
          : null,
      isActive: data['isActive'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'value': value,
      'minPurchase': minPurchase,
      'maxUses': maxUses,
      'usedCount': usedCount,
      'expiresAt': Timestamp.fromDate(expiresAt),
      'applicableCategories': applicableCategories,
      'applicableBrands': applicableBrands,
      'isActive': isActive,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
