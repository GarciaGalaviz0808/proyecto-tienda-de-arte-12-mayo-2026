import 'package:cloud_firestore/cloud_firestore.dart';

class AddressModel {
  final String addrId;
  final String userId;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String phone;
  final bool isDefault;

  AddressModel({
    required this.addrId,
    required this.userId,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.phone,
    required this.isDefault,
  });

  factory AddressModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AddressModel(
      addrId: doc.id,
      userId: data['userId'] ?? '',
      street: data['street'] ?? '',
      city: data['city'] ?? '',
      state: data['state'] ?? '',
      country: data['country'] ?? '',
      postalCode: data['postalCode'] ?? '',
      phone: data['phone'] ?? '',
      isDefault: data['isDefault'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'phone': phone,
      'isDefault': isDefault,
    };
  }

  Map<String, String> toMap() {
    return {
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'phone': phone,
    };
  }
}
