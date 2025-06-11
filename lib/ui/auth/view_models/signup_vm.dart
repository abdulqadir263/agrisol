import 'package:agrisol/data/AuthRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import '../../../data/user_repository.dart';

class SignUpViewModel extends GetxController {
  AuthRepository authRepository = Get.find();
  UserRepository userRepository = Get.find();
  var isLoading = false.obs;

  Future<void> signup(String email, String password, String confirmPassword) async {
    if (!email.contains("@")) {
      Get.snackbar("Error", "Enter valid Email");
      return;
    }
    if (password.length < 6) {
      Get.snackbar("Error", "Password must be of 6 characters");
      return;
    }
    if (password != confirmPassword) {
      Get.snackbar("Error", "Password must be same");
      return;
    }

    isLoading.value = true;
    try {
      final cred = await authRepository.signup(email, password, "");
      final user = cred.user;
      if (user != null) {
        await userRepository.createUserDocument(user: user, username: "");
      }
      Get.offAllNamed("/profile");
    } on FirebaseAuthException catch (e) {
      Get.snackbar("Error", e.message ?? "SignUp Failed");
    }
    isLoading.value = false;
  }

  bool isUserLoggedIn() {
    return authRepository.getLoggedInUser() != null;
  }
}