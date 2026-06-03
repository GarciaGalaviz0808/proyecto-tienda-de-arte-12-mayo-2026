import 'package:cloud_firestore/cloud_firestore.dart';

class AdminPermission {
  final String collection;
  final List<String> actions; // read, write, delete

  AdminPermission({
    required this.collection,
    required this.actions,
  });

  factory AdminPermission.fromMap(Map<String, dynamic> map) {
    return AdminPermission(
      collection: map['collection'] ?? '',
      actions: List<String>.from(map['actions'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'collection': collection,
      'actions': actions,
    };
  }
}

class AdminPermissionModel {
  final String adminId;
  final List<AdminPermission> permissions;
  final String grantedBy;
  final DateTime grantedAt;
  final DateTime updatedAt;

  AdminPermissionModel({
    required this.adminId,
    required this.permissions,
    required this.grantedBy,
    required this.grantedAt,
    required this.updatedAt,
  });

  bool hasPermission(String collection, String action) {
    for (var perm in permissions) {
      if (perm.collection == collection) {
        return perm.actions.contains(action);
      }
    }
    return false;
  }

  bool get canManageProducts => hasPermission('products', 'read') || hasPermission('products', 'write') || hasPermission('products', 'delete');
  bool get canManageOrders => hasPermission('orders', 'read') || hasPermission('orders', 'write') || hasPermission('orders', 'delete');
  bool get canManageUsers => hasPermission('users', 'read') || hasPermission('users', 'write') || hasPermission('users', 'delete');
  bool get canManageLoyalty => hasPermission('loyalty', 'read') || hasPermission('loyalty', 'write') || hasPermission('coupons', 'read') || hasPermission('coupons', 'write');
  bool get isSuperAdmin => hasPermission('admin_permissions', 'read') || hasPermission('admin_permissions', 'write') || hasPermission('admin_permissions', 'delete');

  factory AdminPermissionModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final rawPerms = data['permissions'] as List<dynamic>? ?? [];

    return AdminPermissionModel(
      adminId: doc.id,
      permissions: rawPerms
          .map((p) => AdminPermission.fromMap(p as Map<String, dynamic>))
          .toList(),
      grantedBy: data['grantedBy'] ?? '',
      grantedAt: (data['grantedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'permissions': permissions.map((p) => p.toMap()).toList(),
      'grantedBy': grantedBy,
      'grantedAt': Timestamp.fromDate(grantedAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}
