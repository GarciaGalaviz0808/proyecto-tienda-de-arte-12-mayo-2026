import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/admin_permission_model.dart';

class AdminService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<AdminPermissionModel?> getAdminPermissions(String adminId) async {
    final doc = await _db.collection('admin_permissions').doc(adminId).get();
    if (!doc.exists) return null;
    return AdminPermissionModel.fromFirestore(doc);
  }

  Future<bool> checkPermission(String adminId, String collection, String action) async {
    // Check if user is superadmin first
    final userDoc = await _db.collection('users').doc(adminId).get();
    if (userDoc.exists && userDoc.get('role') == 'superadmin') {
      return true;
    }

    final doc = await _db.collection('admin_permissions').doc(adminId).get();
    if (!doc.exists) return false;
    final permissionsModel = AdminPermissionModel.fromFirestore(doc);
    return permissionsModel.hasPermission(collection, action);
  }

  Future<void> updateCategory(String catId, String newName) async {
    final catRef = _db.collection('categories').doc(catId);
    
    await _db.runTransaction((transaction) async {
      transaction.update(catRef, {'name': newName});

      // Fetch all products under this category
      final productsSnapshot = await _db.collection('products')
          .where('categoryId', isEqualTo: catId)
          .get();

      for (var doc in productsSnapshot.docs) {
        transaction.update(doc.reference, {'categoryName': newName});
      }
    });
  }

  Future<void> updateBrand(String brandId, String newName) async {
    final brandRef = _db.collection('brands').doc(brandId);

    await _db.runTransaction((transaction) async {
      transaction.update(brandRef, {'name': newName});

      // Fetch all products under this brand
      final productsSnapshot = await _db.collection('products')
          .where('brandId', isEqualTo: brandId)
          .get();

      for (var doc in productsSnapshot.docs) {
        transaction.update(doc.reference, {'brandName': newName});
      }
    });
  }

  Future<void> createProduct(ProductModel product, String adminId) async {
    final prodRef = _db.collection('products').doc();
    final movementRef = _db.collection('inventory_movements').doc();

    await _db.runTransaction((transaction) async {
      transaction.set(prodRef, product.toFirestore());

      // Log initial stock movement
      if (product.stock > 0) {
        transaction.set(movementRef, {
          'prodId': prodRef.id,
          'type': 'restock',
          'quantity': product.stock,
          'reason': 'Stock Inicial',
          'adminId': adminId,
          'orderId': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> updateProduct(ProductModel product, String adminId, {int? previousStock}) async {
    final prodRef = _db.collection('products').doc(product.prodId);
    final movementRef = _db.collection('inventory_movements').doc();

    await _db.runTransaction((transaction) async {
      transaction.update(prodRef, product.toFirestore());

      if (previousStock != null && previousStock != product.stock) {
        final diff = product.stock - previousStock;
        transaction.set(movementRef, {
          'prodId': product.prodId,
          'type': diff > 0 ? 'restock' : 'adjustment',
          'quantity': diff,
          'reason': diff > 0 ? 'Reabastecimiento Admin' : 'Ajuste manual de inventario',
          'adminId': adminId,
          'orderId': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  Future<void> softDeleteProduct(String prodId, String adminId) async {
    final prodRef = _db.collection('products').doc(prodId);
    final movementRef = _db.collection('inventory_movements').doc();

    await _db.runTransaction((transaction) async {
      final doc = await transaction.get(prodRef);
      if (!doc.exists) throw Exception('Producto no encontrado.');

      final int currentStock = doc.get('stock') as int? ?? 0;

      transaction.update(prodRef, {
        'isActive': false,
        'status': 'inactive',
      });

      // Clear inventory movement if stock > 0
      if (currentStock > 0) {
        transaction.set(movementRef, {
          'prodId': prodId,
          'type': 'adjustment',
          'quantity': -currentStock,
          'reason': 'Baja de producto (Soft Delete)',
          'adminId': adminId,
          'orderId': null,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }
}
