import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import '../models/category_model.dart';
import '../models/brand_model.dart';
import '../models/banner_model.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _productService = ProductService();

  List<ProductModel> _products = [];
  List<CategoryModel> _categories = [];
  List<BrandModel> _brands = [];
  List<BannerModel> _banners = [];
  bool _isLoading = false;
  String? _error;

  // Filter States
  String? _selectedCategoryId;
  String? _selectedTechnique;
  String? _selectedSkillLevel;
  String? _selectedBrandId;
  double? _minPrice;
  double? _maxPrice;
  String _searchQuery = '';
  bool _onlyOffers = false;

  ProductProvider() {
    _init();
  }

  Future<void> _init() async {
    await Future.wait([
      loadCategories(),
      loadBrands(),
      loadProducts(),
      fetchBanners(),
    ]);
  }

  List<ProductModel> get products => _products;
  List<CategoryModel> get categories => _categories;
  List<BrandModel> get brands => _brands;
  List<BannerModel> get banners => _banners;
  bool get isLoading => _isLoading;
  String? get error => _error;

  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedTechnique => _selectedTechnique;
  String? get selectedSkillLevel => _selectedSkillLevel;
  String? get selectedBrandId => _selectedBrandId;
  double? get minPrice => _minPrice;
  double? get maxPrice => _maxPrice;
  String get searchQuery => _searchQuery;
  bool get onlyOffers => _onlyOffers;

  Future<void> loadCategories() async {
    try {
      _categories = await _productService.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadBrands() async {
    try {
      _brands = await _productService.getBrands();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> loadProducts() async {
    await fetchActiveProducts();
  }

  Future<void> fetchBanners() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('banners')
          .get();
      _banners = snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .where((b) => b.isActive)
          .toList();
      _banners.sort((a, b) => a.displayOrder.compareTo(b.displayOrder));
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchCategories() async {
    try {
      _categories = await _productService.getCategories();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchActiveProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _products = await _productService.getProducts(
        categoryId: _selectedCategoryId,
        technique: _selectedTechnique,
        skillLevel: _selectedSkillLevel,
        brandId: _selectedBrandId,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        searchKeyword: _searchQuery,
        onlyOffers: _onlyOffers,
      );
    } catch (e) {
      _error = e.toString();
      _products = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String? categoryId) {
    _selectedCategoryId = categoryId;
    loadProducts();
  }

  void setFilters({
    String? technique,
    String? skillLevel,
    String? brandId,
    double? minPrice,
    double? maxPrice,
    bool? onlyOffers,
  }) {
    _selectedTechnique = technique;
    _selectedSkillLevel = skillLevel;
    _selectedBrandId = brandId;
    _minPrice = minPrice;
    _maxPrice = maxPrice;
    if (onlyOffers != null) _onlyOffers = onlyOffers;
    loadProducts();
  }

  void clearFilters() {
    _selectedCategoryId = null;
    _selectedTechnique = null;
    _selectedSkillLevel = null;
    _selectedBrandId = null;
    _minPrice = null;
    _maxPrice = null;
    _onlyOffers = false;
    _searchQuery = '';
    loadProducts();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    loadProducts();
  }

  Future<ProductModel> getProductById(String id) async {
    return await _productService.getProductById(id);
  }
}
