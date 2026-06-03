import 'package:flutter/foundation.dart';
import '../models/admin_permission_model.dart';
import '../services/admin_service.dart';

class AdminProvider with ChangeNotifier {
  final AdminService _adminService;
  
  AdminPermissionModel? _permissions;
  bool _isLoading = false;
  String? _error;

  AdminProvider({AdminService? adminService}) : _adminService = adminService ?? AdminService();

  AdminPermissionModel? get permissions => _permissions;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPermissions(String adminId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _permissions = await _adminService.getAdminPermissions(adminId);
    } catch (e) {
      _error = e.toString();
      // If error or not found, fallback to minimum permissions to prevent crash
      // But they shouldn't be here if not admin anyway.
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  bool canManageProducts() => _permissions?.canManageProducts ?? false;
  bool canManageOrders() => _permissions?.canManageOrders ?? false;
  bool canManageUsers() => _permissions?.canManageUsers ?? false;
  bool canManageLoyalty() => _permissions?.canManageLoyalty ?? false;
  bool isSuperAdmin() => _permissions?.isSuperAdmin ?? false;

  void clear() {
    _permissions = null;
    _error = null;
    notifyListeners();
  }
}
