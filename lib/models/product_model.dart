import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String prodId;
  final String name;
  final String description;
  final String categoryId;
  final String categoryName;
  final String brandId;
  final String brandName;
  final String technique; // e.g., óleo, acuarela, dibujo
  final String skillLevel; // principiante | intermedio | profesional
  final double price;
  final double? discountPrice;
  final int stock;
  final String sku;
  final List<String> images;
  final String dimensions;
  final String weight;
  final String materials;
  final double rating;
  final int reviewCount;
  final bool isFeatured;
  final bool isActive;
  final String status; // active | inactive | offer | limited | new | sold_out
  final DateTime createdAt;

  ProductModel({
    required this.prodId,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.categoryName,
    required this.brandId,
    required this.brandName,
    required this.technique,
    required this.skillLevel,
    required this.price,
    this.discountPrice,
    required this.stock,
    required this.sku,
    required this.images,
    required this.dimensions,
    required this.weight,
    required this.materials,
    required this.rating,
    required this.reviewCount,
    required this.isFeatured,
    required this.isActive,
    required this.status,
    required this.createdAt,
  });

  String get id => prodId;
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  double get effectivePrice => hasDiscount ? discountPrice! : price;
  bool get isAvailable => stock > 0 && isActive;

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ProductModel(
      prodId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      categoryId: data['categoryId'] ?? '',
      categoryName: data['categoryName'] ?? '',
      brandId: data['brandId'] ?? '',
      brandName: data['brandName'] ?? '',
      technique: data['technique'] ?? '',
      skillLevel: data['skillLevel'] ?? 'principiante',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      discountPrice: (data['discountPrice'] as num?)?.toDouble(),
      stock: data['stock'] ?? 0,
      sku: data['sku'] ?? '',
      images: List<String>.from(data['images'] ?? []),
      dimensions: data['dimensions'] ?? '',
      weight: data['weight'] ?? '',
      materials: data['materials'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] ?? 0,
      isFeatured: data['isFeatured'] ?? false,
      isActive: data['isActive'] ?? true,
      status: data['status'] ?? 'active',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'categoryId': categoryId,
      'categoryName': categoryName,
      'brandId': brandId,
      'brandName': brandName,
      'technique': technique,
      'skillLevel': skillLevel,
      'price': price,
      'discountPrice': discountPrice,
      'stock': stock,
      'sku': sku,
      'images': images,
      'dimensions': dimensions,
      'weight': weight,
      'materials': materials,
      'rating': rating,
      'reviewCount': reviewCount,
      'isFeatured': isFeatured,
      'isActive': isActive,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
