import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/user.dart';

class UserRepository {
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<void> createUserDocument({
    required User user,
    required String username,
    String? contact,
    String? location,
  }) async {
    final doc = await _usersCollection.doc(user.uid).get();
    if (!doc.exists) {
      await _usersCollection.doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'username': username,
        'contact': contact,
        'location': location,
      });
    }
  }

  Future<void> updateUserProfile(
      String uid, String username, String? contact, String? location) async {
    await _usersCollection.doc(uid).update({
      'username': username,
      'contact': contact,
      'location': location,
    });
  }

  Future<AppUser?> getUserByUid(String uid) async {
    final doc = await _usersCollection.doc(uid).get();
    if (doc.exists) {
      return AppUser.fromMap(doc.data()!);
    }
    return null;
  }

  Future<AppUser?> getUserByEmail(String email) async {
    final query = await _usersCollection.where('email', isEqualTo: email).limit(1).get();
    if (query.docs.isNotEmpty) {
      return AppUser.fromMap(query.docs.first.data());
    }
    return null;
  }

  Future<bool> isUsernameTaken(String username) async {
    final query = await _usersCollection.where('username', isEqualTo: username).limit(1).get();
    return query.docs.isNotEmpty;
  }
}