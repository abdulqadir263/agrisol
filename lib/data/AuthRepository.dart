import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthRepository {
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  Future<UserCredential> login(String email, String password) async {
    final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email, password: password);
    // Ensure user doc exists
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
    // Create user doc on signup
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

  // ---- SAVED POSTS METHODS ----

  Future<List<String>> getSavedPosts() async {
    final user = getLoggedInUser();
    if (user == null) return [];
    final doc = await _usersCollection.doc(user.uid).get();
    if (doc.exists && doc['savedPosts'] != null) {
      return List<String>.from(doc['savedPosts']);
    }
    return [];
  }

  Future<void> savePost(String postId) async {
    final user = getLoggedInUser();
    if (user == null) return;
    await _usersCollection.doc(user.uid).set({
      'savedPosts': FieldValue.arrayUnion([postId])
    }, SetOptions(merge: true));
  }

  Future<void> unsavePost(String postId) async {
    final user = getLoggedInUser();
    if (user == null) return;
    await _usersCollection.doc(user.uid).set({
      'savedPosts': FieldValue.arrayRemove([postId])
    }, SetOptions(merge: true));
  }


  Future<void> resetPassword(String email) {
    return FirebaseAuth.instance.sendPasswordResetEmail(email: email);
  }

  bool isEmailVerified() {
    User? user = getLoggedInUser();
    if (user == null) return false;
    return user.emailVerified;
  }

  Future<void> sendVerificationEmail() {
    User? user = getLoggedInUser();
    if (user == null) return Future.value();
    return user.sendEmailVerification();
  }

  Future<void> changePassword(String newPassword) {
    User? user = getLoggedInUser();
    if (user == null) return Future.value();
    return user.updatePassword(newPassword);
  }

  Future<void> changeName(String name) {
    User? user = getLoggedInUser();
    if (user == null) return Future.value();
    return user.updateDisplayName(name);
  }

  void logout() {
    FirebaseAuth.instance.signOut();
  }
}