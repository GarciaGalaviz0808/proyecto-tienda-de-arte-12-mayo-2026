import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/loyalty_model.dart';
import '../models/user_model.dart';

class LoyaltyService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<LoyaltyRulesModel> getLoyaltyRules() async {
    final doc = await _db.collection('loyalty_rules').doc('global').get();
    if (!doc.exists) {
      final defaultRules = LoyaltyRulesModel.defaultRules();
      await _db.collection('loyalty_rules').doc('global').set(defaultRules.toFirestore());
      return defaultRules;
    }
    return LoyaltyRulesModel.fromFirestore(doc);
  }

  Future<List<LoyaltyTransactionModel>> getUserTransactions(String userId) async {
    final snapshot = await _db.collection('users')
        .doc(userId)
        .collection('loyalty_transactions')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => LoyaltyTransactionModel.fromFirestore(doc)).toList();
  }

  Future<void> redeemReward({
    required String userId,
    required LoyaltyReward reward,
  }) async {
    final userRef = _db.collection('users').doc(userId);
    final rulesRef = _db.collection('loyalty_rules').doc('global');

    await _db.runTransaction((transaction) async {
      // 1. Read user points
      final userDoc = await transaction.get(userRef);
      if (!userDoc.exists) throw Exception('Usuario no encontrado.');
      final user = UserModel.fromFirestore(userDoc);

      // Verify points
      if (user.loyaltyPoints < reward.pointsCost) {
        throw Exception('Puntos de fidelidad insuficientes para canjear "${reward.name}".');
      }

      // 2. Read loyalty rules for levels/thresholds
      final rulesDoc = await transaction.get(rulesRef);
      final loyaltyRules = rulesDoc.exists
          ? LoyaltyRulesModel.fromFirestore(rulesDoc)
          : LoyaltyRulesModel.defaultRules();

      // 3. Calculate new points
      final int newPoints = user.loyaltyPoints - reward.pointsCost;

      // Recalculate level based on thresholds
      String newLevel = 'Bronce';
      int highestThreshold = -1;
      for (var threshold in loyaltyRules.levelThresholds) {
        if (newPoints >= threshold.minPoints && threshold.minPoints > highestThreshold) {
          highestThreshold = threshold.minPoints;
          newLevel = threshold.level;
        }
      }

      // 4. Update user points and level
      transaction.update(userRef, {
        'loyaltyPoints': newPoints,
        'loyaltyLevel': newLevel,
      });

      // 5. Create loyalty transaction record (redeemed)
      final txRef = userRef.collection('loyalty_transactions').doc();
      transaction.set(txRef, {
        'type': 'redeemed',
        'points': reward.pointsCost,
        'orderId': null,
        'rewardId': reward.rewardId,
        'description': 'Recompensa canjeada: ${reward.name}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // 6. Apply reward benefits (create a coupon code in coupons collection for client to use)
      final couponRef = _db.collection('coupons').doc(reward.rewardId + "_" + userId.substring(0, 5));
      
      // Determine coupon settings
      double couponVal = 0.0;
      String couponType = 'fixed';
      if (reward.type == 'discount') {
        couponVal = (reward.value as num?)?.toDouble() ?? 100.0;
        couponType = 'fixed';
      } else if (reward.type == 'free_shipping') {
        couponVal = 0.0;
        couponType = 'free_shipping';
      }

      transaction.set(couponRef, {
        'type': couponType,
        'value': couponVal,
        'minPurchase': 0.0,
        'maxUses': 1,
        'usedCount': 0,
        'expiresAt': Timestamp.fromDate(DateTime.now().add(const Duration(days: 30))),
        'applicableCategories': null,
        'applicableBrands': null,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
