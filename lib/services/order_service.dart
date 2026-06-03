import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';
import '../models/user_model.dart';
import '../models/loyalty_model.dart';

class OrderService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<OrderModel>> getUserOrders(String userId) async {
    final snapshot = await _db.collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => OrderModel.fromFirestore(doc)).toList();
  }

  Future<OrderModel> createOrder({
    required String userId,
    required List<OrderItemModel> items,
    required double subtotal,
    required double shippingCost,
    required String paymentMethod,
    required Map<String, String> shippingAddress,
    String? couponCode,
    double discountAmount = 0.0,
  }) async {
    final orderRef = _db.collection('orders').doc();
    final userRef = _db.collection('users').doc(userId);
    final cartRef = _db.collection('carts').doc(userId);
    final rulesRef = _db.collection('loyalty_rules').doc('global');
    final couponRef = couponCode != null ? _db.collection('coupons').doc(couponCode) : null;

    final result = await _db.runTransaction<OrderModel>((transaction) async {
      // 1. Read product stocks and verify availability
      final productDocs = <String, DocumentSnapshot>{};
      for (var item in items) {
        final prodRef = _db.collection('products').doc(item.prodId);
        final prodDoc = await transaction.get(prodRef);
        if (!prodDoc.exists) {
          throw Exception('El producto "${item.name}" ya no existe.');
        }
        final currentStock = prodDoc.get('stock') as int? ?? 0;
        final isActive = prodDoc.get('isActive') as bool? ?? false;
        
        if (!isActive) {
          throw Exception('El producto "${item.name}" no está disponible.');
        }
        if (currentStock < item.quantity) {
          throw Exception('Stock insuficiente para "${item.name}". Solo quedan $currentStock unidades.');
        }
        productDocs[item.prodId] = prodDoc;
      }

      // 2. Read loyalty rules and user details
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) {
        throw Exception('Usuario no encontrado.');
      }
      final user = UserModel.fromFirestore(userDoc);

      final rulesDoc = await transaction.get(rulesRef);
      final loyaltyRules = rulesDoc.exists 
          ? LoyaltyRulesModel.fromFirestore(rulesDoc) 
          : LoyaltyRulesModel.defaultRules();

      // 3. Read coupon if applicable
      if (couponRef != null) {
        final couponDoc = await transaction.get(couponRef);
        if (!couponDoc.exists) {
          throw Exception('Cupón inválido.');
        }
        final isActive = couponDoc.get('isActive') as bool? ?? false;
        final expiresAt = (couponDoc.get('expiresAt') as Timestamp).toDate();
        final maxUses = couponDoc.get('maxUses') as int? ?? 0;
        final usedCount = couponDoc.get('usedCount') as int? ?? 0;
        
        if (!isActive || expiresAt.isBefore(DateTime.now()) || usedCount >= maxUses) {
          throw Exception('El cupón ya no es válido o ha expirado.');
        }
      }

      // 4. Update product stocks and status
      for (var item in items) {
        final prodRef = _db.collection('products').doc(item.prodId);
        final currentStock = productDocs[item.prodId]!.get('stock') as int? ?? 0;
        final newStock = currentStock - item.quantity;
        final newStatus = newStock == 0 ? 'sold_out' : (productDocs[item.prodId]!.get('status') ?? 'active');

        transaction.update(prodRef, {
          'stock': newStock,
          'status': newStatus,
        });

        // 5. Create inventory movement record
        final movementRef = _db.collection('inventory_movements').doc();
        transaction.set(movementRef, {
          'prodId': item.prodId,
          'type': 'sale',
          'quantity': -item.quantity,
          'reason': 'Venta - Pedido #${orderRef.id.substring(0, 8)}',
          'adminId': null,
          'orderId': orderRef.id,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 6. Calculate loyalty points
      final total = subtotal + shippingCost - discountAmount;
      final int pointsEarned = (total / loyaltyRules.amountDivisor).floor() * loyaltyRules.pointsPerAmount;
      
      final int newPoints = user.loyaltyPoints + pointsEarned;
      
      // Determine new loyalty level
      String newLevel = 'Bronce';
      int highestThreshold = -1;
      for (var threshold in loyaltyRules.levelThresholds) {
        if (newPoints >= threshold.minPoints && threshold.minPoints > highestThreshold) {
          highestThreshold = threshold.minPoints;
          newLevel = threshold.level;
        }
      }

      // 7. Update User points and level
      transaction.update(userRef, {
        'loyaltyPoints': newPoints,
        'loyaltyLevel': newLevel,
      });

      // 8. Create loyalty transaction record
      if (pointsEarned > 0) {
        final txRef = userRef.collection('loyalty_transactions').doc();
        transaction.set(txRef, {
          'type': 'earned',
          'points': pointsEarned,
          'orderId': orderRef.id,
          'rewardId': null,
          'description': 'Puntos ganados por compra en Pedido #${orderRef.id.substring(0, 8)}',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 9. Increment coupon used count if used
      if (couponRef != null) {
        transaction.update(couponRef, {
          'usedCount': FieldValue.increment(1),
        });
      }

      // 10. Clear Cart
      transaction.update(cartRef, {
        'items': [],
        'appliedCoupon': null,
        'discountAmount': 0.0,
        'total': 0.0,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // 11. Save Order Document
      final finalOrder = OrderModel(
        orderId: orderRef.id,
        userId: userId,
        items: items,
        subtotal: subtotal,
        couponCode: couponCode,
        discountAmount: discountAmount,
        shippingCost: shippingCost,
        total: total,
        loyaltyPointsEarned: pointsEarned,
        status: 'pending',
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      transaction.set(orderRef, finalOrder.toFirestore());

      return finalOrder;
    });

    return result;
  }
}
