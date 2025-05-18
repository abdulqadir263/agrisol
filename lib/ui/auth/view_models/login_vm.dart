import 'package:agrisol/data/AuthRepository.dart';
import 'package:agrisol/ui/home/home.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class LoginViewModel extends GetxController{
  AuthRepository authRepository = Get.find();
  var isLoading = false.obs;


  Future<void> login(String email, String password) async {

    if(!email.contains("@")){
      Get.snackbar("Error", "Enter valid Email");
      return;
    }

    if(password.length<6){
      Get.snackbar("Error", "Password must be of 6 characters");
      return;
    }

    isLoading.value = true;
    try{
      await authRepository.login(email, password);
      Get.offAllNamed('/home');
      //Success
    }on FirebaseAuthException catch(e){
      Get.snackbar("Error", e.message ?? "Login Failed");
    }
      isLoading.value = false;
  }

  bool isUserLoggedIn(){
    return authRepository.getLoggedInUser()!=null;
  }

}