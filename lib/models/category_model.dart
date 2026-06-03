import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryModel {
  final String catId;
  final String name;
  final String slug;
  final String iconUrl; // SVG icon URL
  final String description;
  final int displayOrder;
  final bool isActive;

  String? get imageUrl => iconUrl.isNotEmpty ? iconUrl : null;
  
  CategoryModel({
    required this.catId,
    required this.name,
    required this.slug,
    required this.iconUrl,
    required this.description,
    required this.displayOrder,
    required this.isActive,
  });

  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return CategoryModel(
      catId: doc.id,
      name: data['name'] ?? '',
      slug: data['slug'] ?? '',
      iconUrl: data['iconUrl'] ?? '',
      description: data['description'] ?? '',
      displayOrder: data['displayOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'slug': slug,
      'iconUrl': iconUrl,
      'description': description,
      'displayOrder': displayOrder,
      'isActive': isActive,
    };
  }
}
