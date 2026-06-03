import 'package:cloud_firestore/cloud_firestore.dart';

class BrandModel {
  final String brandId;
  final String name;
  final String logoUrl;
  final String country;
  final String description;
  final bool isActive;

  BrandModel({
    required this.brandId,
    required this.name,
    required this.logoUrl,
    required this.country,
    required this.description,
    required this.isActive,
  });

  factory BrandModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return BrandModel(
      brandId: doc.id,
      name: data['name'] ?? '',
      logoUrl: data['logoUrl'] ?? '',
      country: data['country'] ?? '',
      description: data['description'] ?? '',
      isActive: data['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'logoUrl': logoUrl,
      'country': country,
      'description': description,
      'isActive': isActive,
    };
  }
}
