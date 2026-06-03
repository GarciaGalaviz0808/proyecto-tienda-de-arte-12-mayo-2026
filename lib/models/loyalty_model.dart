import 'package:cloud_firestore/cloud_firestore.dart';

class LoyaltyRuleThreshold {
  final String level;
  final int minPoints;
  final String benefit;

  LoyaltyRuleThreshold({
    required this.level,
    required this.minPoints,
    required this.benefit,
  });

  factory LoyaltyRuleThreshold.fromMap(Map<String, dynamic> map) {
    return LoyaltyRuleThreshold(
      level: map['level'] ?? '',
      minPoints: map['minPoints'] ?? 0,
      benefit: map['benefit'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'minPoints': minPoints,
      'benefit': benefit,
    };
  }
}

class LoyaltyReward {
  final String rewardId;
  final String name;
  final int pointsCost;
  final String type; // discount | free_product | free_shipping
  final dynamic value;

  LoyaltyReward({
    required this.rewardId,
    required this.name,
    required this.pointsCost,
    required this.type,
    required this.value,
  });

  factory LoyaltyReward.fromMap(Map<String, dynamic> map) {
    return LoyaltyReward(
      rewardId: map['rewardId'] ?? '',
      name: map['name'] ?? '',
      pointsCost: map['pointsCost'] ?? 0,
      type: map['type'] ?? 'discount',
      value: map['value'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'rewardId': rewardId,
      'name': name,
      'pointsCost': pointsCost,
      'type': type,
      'value': value,
    };
  }
}

class LoyaltyRulesModel {
  final int pointsPerAmount;
  final int amountDivisor;
  final List<LoyaltyRuleThreshold> levelThresholds;
  final List<LoyaltyReward> redeemableRewards;
  final DateTime updatedAt;

  LoyaltyRulesModel({
    required this.pointsPerAmount,
    required this.amountDivisor,
    required this.levelThresholds,
    required this.redeemableRewards,
    required this.updatedAt,
  });

  factory LoyaltyRulesModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final thresholds = data['levelThresholds'] as List<dynamic>? ?? [];
    final rewards = data['redeemableRewards'] as List<dynamic>? ?? [];

    return LoyaltyRulesModel(
      pointsPerAmount: data['pointsPerAmount'] ?? 1,
      amountDivisor: data['amountDivisor'] ?? 10,
      levelThresholds: thresholds
          .map((t) => LoyaltyRuleThreshold.fromMap(t as Map<String, dynamic>))
          .toList(),
      redeemableRewards: rewards
          .map((r) => LoyaltyReward.fromMap(r as Map<String, dynamic>))
          .toList(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'pointsPerAmount': pointsPerAmount,
      'amountDivisor': amountDivisor,
      'levelThresholds': levelThresholds.map((t) => t.toMap()).toList(),
      'redeemableRewards': redeemableRewards.map((r) => r.toMap()).toList(),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory LoyaltyRulesModel.defaultRules() {
    return LoyaltyRulesModel(
      pointsPerAmount: 1,
      amountDivisor: 10,
      levelThresholds: [
        LoyaltyRuleThreshold(level: "Bronce", minPoints: 0, benefit: "5% descuento en siguiente compra"),
        LoyaltyRuleThreshold(level: "Plata", minPoints: 500, benefit: "10% descuento + envío gratis"),
        LoyaltyRuleThreshold(level: "Oro", minPoints: 1500, benefit: "15% descuento + acceso anticipado"),
        LoyaltyRuleThreshold(level: "Platino", minPoints: 3000, benefit: "20% descuento + kit sorpresa trimestral"),
      ],
      redeemableRewards: [
        LoyaltyReward(rewardId: "desc_100", name: "\$100 de Descuento", pointsCost: 200, type: "discount", value: 100.0),
        LoyaltyReward(rewardId: "envio_gratis", name: "Envío Gratis", pointsCost: 100, type: "free_shipping", value: 0.0),
      ],
      updatedAt: DateTime.now(),
    );
  }
}

class LoyaltyTransactionModel {
  final String txId;
  final String type; // earned | redeemed
  final int points;
  final String? orderId;
  final String? rewardId;
  final String description;
  final DateTime createdAt;

  LoyaltyTransactionModel({
    required this.txId,
    required this.type,
    required this.points,
    this.orderId,
    this.rewardId,
    required this.description,
    required this.createdAt,
  });

  factory LoyaltyTransactionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return LoyaltyTransactionModel(
      txId: doc.id,
      type: data['type'] ?? 'earned',
      points: data['points'] ?? 0,
      orderId: data['orderId'],
      rewardId: data['rewardId'],
      description: data['description'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'points': points,
      'orderId': orderId,
      'rewardId': rewardId,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
