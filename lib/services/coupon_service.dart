import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/coupon_model.dart';

class CouponService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<CouponModel> validateCoupon({
    required String code,
    required String userId,
    required double subtotal,
    required List<Map<String, dynamic>> items, // List of { 'categoryId': '', 'brandId': '' }
  }) async {
    final doc = await _db.collection('coupons').doc(code).get();
    if (!doc.exists) {
      throw Exception('El cupón "$code" no existe.');
    }

    final coupon = CouponModel.fromFirestore(doc);

    if (!coupon.isActive) {
      throw Exception('El cupón "$code" no está activo.');
    }

    if (coupon.isExpired) {
      throw Exception('El cupón "$code" ha expirado.');
    }

    if (coupon.isLimitReached) {
      throw Exception('El cupón "$code" ha alcanzado el límite máximo de usos.');
    }

    if (subtotal < coupon.minPurchase) {
      throw Exception('La compra mínima para este cupón es de \$${coupon.minPurchase.toStringAsFixed(2)}.');
    }

    // Validate applicable categories if specified
    if (coupon.applicableCategories != null && coupon.applicableCategories!.isNotEmpty) {
      bool categoryMatch = items.any((item) => coupon.applicableCategories!.contains(item['categoryId']));
      if (!categoryMatch) {
        throw Exception('El cupón no es aplicable a las categorías en tu carrito.');
      }
    }

    // Validate applicable brands if specified
    if (coupon.applicableBrands != null && coupon.applicableBrands!.isNotEmpty) {
      bool brandMatch = items.any((item) => coupon.applicableBrands!.contains(item['brandId']));
      if (!brandMatch) {
        throw Exception('El cupón no es aplicable a las marcas en tu carrito.');
      }
    }

    return coupon;
  }
}
