import 'package:agrisol/data/AuthRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ResetPasswordViewModel extends GetxController{
  AuthRepository authRepository = Get.find();
  var isLoading = false.obs;


  Future<void> reset(String email) async {

    if(!email.contains("@")){
      Get.snackbar("Error", "Enter valid Email");
      return;
    }

    isLoading.value = true;
    try{
      await authRepository.resetPassword(email);
      Get.snackbar("Reset Password", "An email has been sent to you at ${email}");
      Get.back();
      
    }on FirebaseAuthException catch(e){
      Get.snackbar("Error", e.message ?? "Failed to send reset password email");
    }
      isLoading.value = false;
  }

}