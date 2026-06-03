import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService;
  UserModel? _currentUser;
  bool _isLoading = true;
  bool _isInitialized = false;

  AuthProvider([AuthService? authService]) : _authService = authService ?? AuthService() {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  UserModel? get currentUser => _currentUser;
  UserModel? get userModel => _currentUser;
  User? get user => _authService.currentUser;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isAuthenticated => _currentUser != null;

  bool get isAdmin => _currentUser != null && 
      (_currentUser!.role == 'admin' || _currentUser!.role == 'superadmin');

  bool get isSuperAdmin => _currentUser != null && _currentUser!.role == 'superadmin';

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _currentUser = null;
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      return;
    }

    if (_currentUser != null && _currentUser!.uid == firebaseUser.uid) {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getUserModel(firebaseUser.uid);
    } catch (e) {
      _currentUser = null;
    }

    _isInitialized = true;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      final user = _authService.currentUser;
      if (user != null) {
        _currentUser = await _authService.getUserModel(user.uid);
        _isInitialized = true;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    String? favoriteTechnique,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _authService.registerWithEmailAndPassword(
        email: email,
        password: password,
        username: username,
        favoriteTechnique: favoriteTechnique,
      );
      final user = _authService.currentUser;
      if (user != null) {
        _currentUser = await _authService.getUserModel(user.uid);
        _isInitialized = true;
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentUser = null;
    notifyListeners();
  }

  Future<void> signOut() => logout();

  Future<void> refreshUser() async {
    if (_currentUser != null) {
      _currentUser = await _authService.getUserModel(_currentUser!.uid);
      notifyListeners();
    }
  }
}
