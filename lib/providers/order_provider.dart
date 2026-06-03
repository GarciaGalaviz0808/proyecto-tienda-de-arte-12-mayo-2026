import 'package:flutter/material.dart';
import '../services/order_service.dart';
import '../models/order_model.dart';

class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();
  final String? uid;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  String? _errorMessage;

  OrderProvider({this.uid}) {
    if (uid != null) {
      loadOrders();
    } else {
      _orders = [];
    }
  }

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadOrders() async {
    if (uid == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getUserOrders(uid!);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchUserOrders(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _orders = await _orderService.getUserOrders(userId);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<OrderModel> placeOrder({
    required List<OrderItemModel> items,
    required double subtotal,
    required double shippingCost,
    required String paymentMethod,
    required Map<String, String> shippingAddress,
    String? couponCode,
    double discountAmount = 0.0,
  }) async {
    if (uid == null) throw Exception('Usuario no autenticado.');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final order = await _orderService.createOrder(
        userId: uid!,
        items: items,
        subtotal: subtotal,
        shippingCost: shippingCost,
        paymentMethod: paymentMethod,
        shippingAddress: shippingAddress,
        couponCode: couponCode,
        discountAmount: discountAmount,
      );
      await loadOrders();
      return order;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
