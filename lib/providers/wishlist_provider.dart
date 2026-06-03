import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import 'auth_provider.dart';

class WishlistProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthProvider? authProvider;

  List<ProductModel> _wishlistItems = [];
  bool _isLoading = false;

  WishlistProvider({this.authProvider}) {
    if (authProvider?.currentUser != null) {
      loadWishlist();
    } else {
      _wishlistItems = [];
    }
  }

  List<ProductModel> get wishlistItems => _wishlistItems;
  List<ProductModel> get wishlistProducts => _wishlistItems;
  List<String> get wishlistIds => authProvider?.currentUser?.wishlist ?? [];
  bool get isLoading => _isLoading;

  bool isFavorite(String prodId) {
    return wishlistIds.contains(prodId);
  }

  Future<void> toggleFavorite(String prodId) async {
    if (authProvider?.currentUser == null) return;
    final uid = authProvider!.currentUser!.uid;
    final list = List<String>.from(wishlistIds);

    if (list.contains(prodId)) {
      list.remove(prodId);
      _wishlistItems.removeWhere((item) => item.prodId == prodId);
      try {
        await _db.collection('users').doc(uid).update({
          'wishlist': list,
        });
        await authProvider!.refreshUser();
      } catch (_) {}
      notifyListeners();
    } else {
      try {
        final product = await _productService.getProductById(prodId);
        await toggleWishlist(product);
      } catch (_) {}
    }
  }

  Future<void> loadWishlist() async {
    if (authProvider?.currentUser == null) return;
    _isLoading = true;
    notifyListeners();

    try {
      _wishlistItems = await _productService.getProductsByIds(wishlistIds);
    } catch (_) {
      _wishlistItems = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleWishlist(ProductModel product) async {
    if (authProvider?.currentUser == null) return;
    final uid = authProvider!.currentUser!.uid;
    final list = List<String>.from(wishlistIds);

    if (list.contains(product.prodId)) {
      list.remove(product.prodId);
      _wishlistItems.removeWhere((item) => item.prodId == product.prodId);
    } else {
      list.add(product.prodId);
      _wishlistItems.add(product);
    }

    try {
      await _db.collection('users').doc(uid).update({
        'wishlist': list,
      });
      await authProvider!.refreshUser();
    } catch (_) {}
    notifyListeners();
  }
}
