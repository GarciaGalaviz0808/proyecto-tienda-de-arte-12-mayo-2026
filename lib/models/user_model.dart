import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String email;
  final String username;
  final String role; // customer | admin | superadmin
  final String? phone;
  final String? photoUrl;
  final String? favoriteTechnique;
  final int loyaltyPoints;
  final String loyaltyLevel; // Bronce | Plata | Oro | Platino
  final List<String> wishlist;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.email,
    required this.username,
    required this.role,
    this.phone,
    this.photoUrl,
    this.favoriteTechnique,
    required this.loyaltyPoints,
    required this.loyaltyLevel,
    required this.wishlist,
    required this.createdAt,
    required this.lastLogin,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      role: data['role'] ?? 'customer',
      phone: data['phone'],
      photoUrl: data['photoUrl'],
      favoriteTechnique: data['favoriteTechnique'],
      loyaltyPoints: data['loyaltyPoints'] ?? 0,
      loyaltyLevel: data['loyaltyLevel'] ?? 'Bronce',
      wishlist: List<String>.from(data['wishlist'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastLogin: (data['lastLogin'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'role': role,
      'phone': phone,
      'photoUrl': photoUrl,
      'favoriteTechnique': favoriteTechnique,
      'loyaltyPoints': loyaltyPoints,
      'loyaltyLevel': loyaltyLevel,
      'wishlist': wishlist,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastLogin': Timestamp.fromDate(lastLogin),
    };
  }

  UserModel copyWith({
    String? username,
    String? role,
    String? phone,
    String? photoUrl,
    String? favoriteTechnique,
    int? loyaltyPoints,
    String? loyaltyLevel,
    List<String>? wishlist,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      username: username ?? this.username,
      role: role ?? this.role,
      phone: phone ?? this.phone,
      photoUrl: photoUrl ?? this.photoUrl,
      favoriteTechnique: favoriteTechnique ?? this.favoriteTechnique,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      loyaltyLevel: loyaltyLevel ?? this.loyaltyLevel,
      wishlist: wishlist ?? this.wishlist,
      createdAt: createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}
