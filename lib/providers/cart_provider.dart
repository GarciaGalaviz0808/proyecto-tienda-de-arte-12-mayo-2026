import 'package:flutter/material.dart';
import '../services/cart_service.dart';
import '../services/coupon_service.dart';
import '../models/cart_model.dart';
import '../models/product_model.dart';

class CartProvider extends ChangeNotifier {
  final CartService _cartService = CartService();
  final CouponService _couponService = CouponService();
  final String? uid;

  CartModel? _cart;
  bool _isLoading = false;
  String? _errorMessage;

  CartProvider({this.uid}) {
    if (uid != null) {
      loadCart();
    } else {
      _cart = null;
    }
  }

  CartModel? get cart => _cart;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get subtotal => _cart?.subtotal ?? 0.0;
  double get discountAmount => _cart?.discountAmount ?? 0.0;
  double get shippingCost => (subtotal > 0 && subtotal < 500) ? 99.0 : 0.0; // Free shipping above $500
  double get total => subtotal + shippingCost - discountAmount;

  Future<void> loadCart() async {
    if (uid == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _cart = await _cartService.getCart(uid!);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(ProductModel product, int quantity) async {
    if (uid == null || _cart == null) return;
    _errorMessage = null;

    // Check stock
    if (product.stock < quantity) {
      _errorMessage = 'Stock insuficiente. Solo quedan ${product.stock} unidades.';
      notifyListeners();
      return;
    }

    final items = List<CartItemModel>.from(_cart!.items);
    final existingIndex = items.indexWhere((item) => item.prodId == product.prodId);

    if (existingIndex >= 0) {
      final newQty = items[existingIndex].quantity + quantity;
      if (product.stock < newQty) {
        _errorMessage = 'No se puede agregar más unidades. Límite de stock: ${product.stock}';
        notifyListeners();
        return;
      }
      items[existingIndex] = items[existingIndex].copyWith(quantity: newQty);
    } else {
      items.add(CartItemModel(
        prodId: product.prodId,
        nameSnapshot: product.name,
        priceSnapshot: product.effectivePrice,
        brandSnapshot: product.brandName,
        imageUrl: product.images.isNotEmpty ? product.images.first : '',
        quantity: quantity,
      ));
    }

    _cart = CartModel(
      cartId: _cart!.cartId,
      userId: _cart!.userId,
      items: items,
      appliedCoupon: _cart!.appliedCoupon,
      discountAmount: _cart!.discountAmount,
      total: total,
      updatedAt: DateTime.now(),
    );

    // If coupon is already applied, revalidate it with new items
    if (_cart!.appliedCoupon != null) {
      try {
        await applyCoupon(_cart!.appliedCoupon!);
      } catch (_) {
        // If revalidation fails, remove coupon
        removeCoupon();
      }
    }

    await _cartService.saveCart(_cart!);
    notifyListeners();
  }

  Future<void> updateQuantity(String prodId, int newQuantity, int stockLimit) async {
    if (uid == null || _cart == null) return;
    _errorMessage = null;

    if (newQuantity > stockLimit) {
      _errorMessage = 'No se puede exceder el stock disponible ($stockLimit unidades).';
      notifyListeners();
      return;
    }

    final items = List<CartItemModel>.from(_cart!.items);
    final index = items.indexWhere((item) => item.prodId == prodId);

    if (index >= 0) {
      if (newQuantity <= 0) {
        items.removeAt(index);
      } else {
        items[index] = items[index].copyWith(quantity: newQuantity);
      }
    }

    _cart = CartModel(
      cartId: _cart!.cartId,
      userId: _cart!.userId,
      items: items,
      appliedCoupon: _cart!.appliedCoupon,
      discountAmount: _cart!.discountAmount,
      total: total,
      updatedAt: DateTime.now(),
    );

    // Revalidate coupon
    if (_cart!.appliedCoupon != null) {
      try {
        await applyCoupon(_cart!.appliedCoupon!);
      } catch (_) {
        removeCoupon();
      }
    }

    await _cartService.saveCart(_cart!);
    notifyListeners();
  }

  Future<void> removeItem(String prodId) async {
    await updateQuantity(prodId, 0, 9999);
  }

  Future<void> applyCoupon(String code) async {
    if (uid == null || _cart == null) return;
    _errorMessage = null;

    try {
      final itemsInfo = _cart!.items.map((i) => {
        'categoryId': '', // categoryId snapshot can be loaded or queried if needed, but in our simplified model we validate global minimums.
        'brandId': '',
      }).toList();

      final coupon = await _couponService.validateCoupon(
        code: code,
        userId: uid!,
        subtotal: subtotal,
        items: itemsInfo,
      );

      double discount = 0.0;
      if (coupon.type == 'percentage') {
        discount = subtotal * (coupon.value / 100);
      } else if (coupon.type == 'fixed') {
        discount = coupon.value;
      } else if (coupon.type == 'free_shipping') {
        discount = shippingCost;
      }

      // Cap discount to subtotal
      if (discount > subtotal) {
        discount = subtotal;
      }

      _cart = CartModel(
        cartId: _cart!.cartId,
        userId: _cart!.userId,
        items: _cart!.items,
        appliedCoupon: code,
        discountAmount: discount,
        total: subtotal + shippingCost - discount,
        updatedAt: DateTime.now(),
      );

      await _cartService.saveCart(_cart!);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      rethrow;
    }
  }

  Future<void> removeCoupon() async {
    if (uid == null || _cart == null) return;
    _errorMessage = null;

    _cart = CartModel(
      cartId: _cart!.cartId,
      userId: _cart!.userId,
      items: _cart!.items,
      appliedCoupon: null,
      discountAmount: 0.0,
      total: subtotal + shippingCost,
      updatedAt: DateTime.now(),
    );

    await _cartService.saveCart(_cart!);
    notifyListeners();
  }

  Future<void> clearCart() async {
    if (uid == null) return;
    await _cartService.clearCart(uid!);
    await loadCart();
  }
}
