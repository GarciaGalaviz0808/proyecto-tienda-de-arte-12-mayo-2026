import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/review_model.dart';

class ReviewService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ReviewModel>> getProductReviews(String prodId) async {
    final snapshot = await _db.collection('products')
        .doc(prodId)
        .collection('reviews')
        .orderBy('createdAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
  }

  Future<void> addReview({
    required String prodId,
    required String userId,
    required String username,
    required String userLevel,
    required double rating,
    required String comment,
    List<String>? images,
    bool verifiedPurchase = false,
  }) async {
    final productRef = _db.collection('products').doc(prodId);
    final reviewRef = productRef.collection('reviews').doc();

    await _db.runTransaction((transaction) async {
      final productDoc = await transaction.get(productRef);
      if (!productDoc.exists) throw Exception('Producto no encontrado.');

      final double oldRating = (productDoc.get('rating') as num?)?.toDouble() ?? 0.0;
      final int oldCount = productDoc.get('reviewCount') as int? ?? 0;

      final int newCount = oldCount + 1;
      final double newRating = ((oldRating * oldCount) + rating) / newCount;

      // Update product document
      transaction.update(productRef, {
        'rating': newRating,
        'reviewCount': newCount,
      });

      // Save review document
      transaction.set(reviewRef, {
        'userId': userId,
        'username': username,
        'userLevel': userLevel,
        'rating': rating,
        'comment': comment,
        'images': images,
        'verifiedPurchase': verifiedPurchase,
        'isAdminResponse': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
