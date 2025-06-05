import 'package:agrisol/data/AuthRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../data/user_repository.dart';

class LoginViewModel extends GetxController {
  AuthRepository authRepository = Get.find();
  UserRepository userRepository = Get.find();
  var isLoading = false.obs;

  Future<void> login(String email, String password) async {
    if (!email.contains("@")) {
      Get.snackbar("Error", "Enter valid Email");
      return;
    }
    if (password.length < 6) {
      Get.snackbar("Error", "Password must be of 6 characters");
      return;
    }

    isLoading.value = true;
    try {
      final cred = await authRepository.login(email, password);
      final user = cred.user;
      if (user != null) {
        // Optionally ensure Firestore user doc exists (if user signed up prior to profile system)
        await userRepository.createUserDocument(
          user: user,
          username: "", // username is required, but for legacy logins we set empty string; consider fetching actual username if needed
        );
      }
      // Check if profile is complete (username not empty/null)
      final appUser = await userRepository.getUserByUid(user!.uid);
      if (appUser == null || appUser.username.isEmpty) {
        // Force user to complete profile before proceeding
        Get.offAllNamed('/profile', arguments: {'isFirstTime': true});
      } else {
        Get.offAllNamed('/posts');
      }
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "Login Failed");
    }
    isLoading.value = false;
  }

  bool isUserLoggedIn() {
    return authRepository.getLoggedInUser() != null;
  }
}