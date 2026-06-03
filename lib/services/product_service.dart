import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/brand_model.dart';

class ProductService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<List<ProductModel>> getProducts({
    String? categoryId,
    String? technique,
    String? skillLevel,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    String? searchKeyword,
    bool? onlyOffers,
    bool? onlyFeatured,
  }) async {
    try {
      Query query = _db.collection('products').where('isActive', isEqualTo: true);

      if (categoryId != null && categoryId.isNotEmpty) {
        query = query.where('categoryId', isEqualTo: categoryId);
      }
      if (technique != null && technique.isNotEmpty) {
        query = query.where('technique', isEqualTo: technique);
      }
      if (skillLevel != null && skillLevel.isNotEmpty) {
        query = query.where('skillLevel', isEqualTo: skillLevel);
      }
      if (brandId != null && brandId.isNotEmpty) {
        query = query.where('brandId', isEqualTo: brandId);
      }
      if (onlyFeatured == true) {
        query = query.where('isFeatured', isEqualTo: true);
      }

      final snapshot = await query.get();
      List<ProductModel> products = snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();

      // In-memory filters
      if (onlyOffers == true) {
        products = products.where((p) => p.discountPrice != null && p.discountPrice! < p.price).toList();
      }
      if (minPrice != null) {
        products = products.where((p) => p.effectivePrice >= minPrice).toList();
      }
      if (maxPrice != null) {
        products = products.where((p) => p.effectivePrice <= maxPrice).toList();
      }
      if (searchKeyword != null && searchKeyword.trim().isNotEmpty) {
        final kw = searchKeyword.toLowerCase();
        products = products.where((p) => p.name.toLowerCase().contains(kw) || p.description.toLowerCase().contains(kw)).toList();
      }

      products.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return products;
    } catch (e) {
      return [];
    }
  }

  Future<List<ProductModel>> getAllProducts() async {
    try {
      final snapshot = await _db.collection('products').orderBy('createdAt', descending: true).get();
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<ProductModel> getProductById(String id) async {
    final doc = await _db.collection('products').doc(id).get();
    if (!doc.exists) throw Exception('Product not found.');
    return ProductModel.fromFirestore(doc);
  }

  Future<List<CategoryModel>> getCategories() async {
    try {
      final snapshot = await _db.collection('categories').get();
      final categories = snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .where((c) => c.isActive)
          .toList();
      categories.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      return categories;
    } catch (e) {
      return [];
    }
  }

  Future<List<BrandModel>> getBrands() async {
    try {
      final snapshot = await _db.collection('brands').get();
      final brands = snapshot.docs
          .map((doc) => BrandModel.fromFirestore(doc))
          .where((b) => b.isActive)
          .toList();
      brands.sort((a, b) => a.name.compareTo(b.name));
      return brands;
    } catch (e) {
      return [];
    }
  }

  Future<List<ProductModel>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];

    final List<ProductModel> products = [];
    for (var id in ids) {
      try {
        final prod = await getProductById(id);
        if (prod.isActive) {
          products.add(prod);
        }
      } catch (_) {
        // Skip missing products
      }
    }
    return products;
  }
}
