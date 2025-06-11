import 'package:firebase_auth/firebase_auth.dart';
import '../data/user_repository.dart';
import '../model/user.dart';

class AuthRepository {
  final _userRepo = UserRepository();

  Future<UserCredential> login(String email, String password){
    return FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signup(String email, String password, String username, {String? contact, String? location}) async {
    final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
    await _userRepo.createUserDocument(
      user: cred.user!,
      username: username,
      contact: contact,
      location: location,
    );
    return cred;
  }

  String? getCurrentUserName() {
    return FirebaseAuth.instance.currentUser?.displayName;
  }

  User? getLoggedInUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<AppUser?> getCurrentAppUser() async {
    final user = getLoggedInUser();
    if (user == null) return null;
    return await _userRepo.getUserByUid(user.uid);
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