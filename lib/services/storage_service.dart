import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePhoto(String userId, File file) async {
    try {
      final ref = _storage.ref().child('profiles').child(userId).child('avatar.jpg');
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      // Fallback placeholder profile URL for simulation/offline mode
      return 'https://api.dicebear.com/7.x/bottts/svg?seed=$userId';
    }
  }

  Future<String> uploadReviewImage(String prodId, String userId, File file) async {
    try {
      final String filename = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      final ref = _storage.ref().child('reviews').child(prodId).child(userId).child(filename);
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      // Fallback simulated review image placeholder
      return 'https://picsum.photos/400/300';
    }
  }
}
