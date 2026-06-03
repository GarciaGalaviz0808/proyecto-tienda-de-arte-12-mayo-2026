import 'package:cloud_firestore/cloud_firestore.dart';

class BannerModel {
  final String bannerId;
  final String title;
  final String imageUrl;
  final String redirectUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int displayOrder;
  final bool isActive;
  final String? targetAudience; // all | customer | loyalty_gold

  BannerModel({
    required this.bannerId,
    required this.title,
    required this.imageUrl,
    required this.redirectUrl,
    required this.startDate,
    required this.endDate,
    required this.displayOrder,
    required this.isActive,
    this.targetAudience,
  });

  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BannerModel(
      bannerId: doc.id,
      title: data['title'] ?? 'Eli\'s Art Supplies',
      imageUrl: data['imageUrl'] ?? '',
      redirectUrl: data['redirectUrl'] ?? '',
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (data['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      displayOrder: data['displayOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
      targetAudience: data['targetAudience'] ?? 'all',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'imageUrl': imageUrl,
      'redirectUrl': redirectUrl,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'displayOrder': displayOrder,
      'isActive': isActive,
      'targetAudience': targetAudience,
    };
  }
}
