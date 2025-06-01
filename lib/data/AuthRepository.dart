import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<UserCredential> login(String email, String password) async {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: password);
    final doc = await _usersCollection.doc(cred.user!.uid).get();
    if (!doc.exists) {
      await _usersCollection.doc(cred.user!.uid).set({
        'uid': cred.user!.uid,
        'email': cred.user!.email,
        'savedPosts': [],
      });
    }
    return cred;
  }

  Future<UserCredential> signup(String email, String password) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email, password: password);
    await _usersCollection.doc(cred.user!.uid).set({
      'uid': cred.user!.uid,
      'email': cred.user!.email,
      'savedPosts': [],
    });
    return cred;
  }

  String? getCurrentUserName() {
    return FirebaseAuth.instance.currentUser?.displayName;
  }

  User? getLoggedInUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<void> resetPassword(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  Future<void> changePassword(String newPassword) {
    User? user = getLoggedInUser();
    if (user == null) return Future.value();
    return user.updatePassword(newPassword);
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }
}