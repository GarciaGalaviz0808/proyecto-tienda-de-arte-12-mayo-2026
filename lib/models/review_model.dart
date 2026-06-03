import 'package:cloud_firestore/cloud_firestore.dart';

class ReviewModel {
  final String reviewId;
  final String userId;
  final String username;
  final String userLevel;
  final double rating;
  final String comment;
  final List<String>? images;
  final bool verifiedPurchase;
  final bool isAdminResponse;
  final DateTime createdAt;

  ReviewModel({
    required this.reviewId,
    required this.userId,
    required this.username,
    required this.userLevel,
    required this.rating,
    required this.comment,
    this.images,
    required this.verifiedPurchase,
    required this.isAdminResponse,
    required this.createdAt,
  });

  factory ReviewModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ReviewModel(
      reviewId: doc.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userLevel: data['userLevel'] ?? 'Bronce',
      rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
      comment: data['comment'] ?? '',
      images: data['images'] != null ? List<String>.from(data['images']) : null,
      verifiedPurchase: data['verifiedPurchase'] ?? false,
      isAdminResponse: data['isAdminResponse'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'username': username,
      'userLevel': userLevel,
      'rating': rating,
      'comment': comment,
      'images': images,
      'verifiedPurchase': verifiedPurchase,
      'isAdminResponse': isAdminResponse,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
