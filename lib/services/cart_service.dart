import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cart_model.dart';

class CartService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<CartModel> getCart(String userId) async {
    final doc = await _db.collection('carts').doc(userId).get();
    if (!doc.exists) {
      // Create empty cart document
      final emptyCart = CartModel.empty(userId);
      await _db.collection('carts').doc(userId).set(emptyCart.toFirestore());
      return emptyCart;
    }
    return CartModel.fromFirestore(doc);
  }

  Future<void> saveCart(CartModel cart) async {
    await _db.collection('carts').doc(cart.userId).set(
      cart.toFirestore(),
      SetOptions(merge: true),
    );
  }

  Future<void> clearCart(String userId) async {
    final emptyCart = CartModel.empty(userId);
    await saveCart(emptyCart);
  }
}
