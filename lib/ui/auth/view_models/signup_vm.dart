import 'package:agrisol/data/AuthRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class SignUpViewModel extends GetxController{
  AuthRepository authRepository = Get.find();
  var isLoading = false.obs;


  Future<void> signup(String email, String password, String confirmPassword) async {

    if(!email.contains("@")){
      Get.snackbar("Error", "Enter valid Email");
      return;
    }

    if(password.length<6){
      Get.snackbar("Error", "Password must be of 6 characters");
      return;
    }

    if(password!=confirmPassword){
      Get.snackbar("Error", "Password must be same");
      return;
    }

    isLoading.value = true;
    try{
      await authRepository.signup(email, password);
      Get.offAllNamed('/home');
      //Success
    }on FirebaseAuthException catch(e){
      Get.snackbar("Error", e.message ?? "SignUp Failed");
    }
      isLoading.value = false;
  }

  bool isUserLoggedIn(){
    return authRepository.getLoggedInUser()!=null;
  }

}