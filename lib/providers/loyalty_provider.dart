import 'package:flutter/material.dart';
import '../services/loyalty_service.dart';
import '../models/loyalty_model.dart';

class LoyaltyProvider extends ChangeNotifier {
  final LoyaltyService _loyaltyService = LoyaltyService();
  final String? uid;

  LoyaltyRulesModel? _rules;
  List<LoyaltyTransactionModel> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  LoyaltyProvider({this.uid}) {
    loadRules();
    if (uid != null) {
      loadTransactions();
    }
  }

  LoyaltyRulesModel? get rules => _rules;
  List<LoyaltyTransactionModel> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> loadRules() async {
    try {
      _rules = await _loyaltyService.getLoyaltyRules();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadTransactions() async {
    if (uid == null) return;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _loyaltyService.getUserTransactions(uid!);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> redeemReward(LoyaltyReward reward) async {
    if (uid == null) throw Exception('Usuario no autenticado.');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _loyaltyService.redeemReward(userId: uid!, reward: reward);
      await loadTransactions();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
