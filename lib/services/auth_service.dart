import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Future<UserModel?> get currentUserModel async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await getUserModel(user.uid);
  }

  Future<UserModel> getUserModel(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) {
      throw Exception('User profile not found in database.');
    }
    return UserModel.fromFirestore(doc);
  }

  Future<UserCredential> signInWithEmailAndPassword(String email, String password) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Update last login
      await _db.collection('users').doc(cred.user!.uid).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
      return cred;
    } catch (e) {
      rethrow;
    }
  }

  Future<UserCredential> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String username,
    String? favoriteTechnique,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      
      final isAdminEmail = email.toLowerCase() == 'admin@gmail.com';
      final role = isAdminEmail ? 'superadmin' : 'customer';

      final newUser = UserModel(
        uid: cred.user!.uid,
        email: email,
        username: username,
        role: role,
        phone: null,
        photoUrl: null,
        favoriteTechnique: favoriteTechnique,
        loyaltyPoints: 0,
        loyaltyLevel: 'Bronce',
        wishlist: [],
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );

      await _db.collection('users').doc(cred.user!.uid).set(newUser.toFirestore());

      if (isAdminEmail) {
        await _db.collection('admin_permissions').doc(cred.user!.uid).set({
          'permissions': [
            {'collection': 'products', 'actions': ['read', 'write', 'delete']},
            {'collection': 'orders', 'actions': ['read', 'write', 'delete']},
            {'collection': 'users', 'actions': ['read', 'write', 'delete']},
            {'collection': 'loyalty', 'actions': ['read', 'write']},
            {'collection': 'coupons', 'actions': ['read', 'write']},
            {'collection': 'admin_permissions', 'actions': ['read', 'write', 'delete']},
          ],
          'grantedBy': 'system',
          'grantedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      return cred;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
