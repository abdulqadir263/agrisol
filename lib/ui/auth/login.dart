import 'package:agrisol/ui/auth/view_models/login_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:agrisol/ui/posts/posts.dart';

import '../../data/AuthRepository.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  late LoginViewModel loginViewModel;

  @override
  void initState() {
    super.initState();
    loginViewModel = Get.find();

    if(loginViewModel.isUserLoggedIn()){
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Get.offAllNamed('/your-route');
      });
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Login to Continue", style: TextStyle(fontSize: 20),),

            const SizedBox(height: 20),
            // Email Field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter your email",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            TextField(
              obscureText: _obscurePassword,
              controller: passwordController,
              decoration: InputDecoration(
                labelText: "Password",
                hintText: "Enter your password",
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
            const SizedBox(height: 30),

            // Login Button
            Obx(() {
              return loginViewModel.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  loginViewModel.login(
                    emailController.text,
                    passwordController.text,
                  );
                },
                child: const Text(
                  "LOGIN",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }
            ),

            const SizedBox(height: 15),

            TextButton(
                onPressed: () {
                  Get.offAllNamed('/signup');
                },
                child: Text(
                    "Create New Account/SignUp",
                    style: TextStyle(fontSize: 16),
                )
            ),


            const SizedBox(height: 15),

            TextButton(
                onPressed: () {
                  Get.toNamed('/forget_password', arguments: emailController.text);
                },
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(fontSize: 16),
                )
            ),

            const SizedBox(height: 15),

            TextButton(
                onPressed: () {
                  Get.toNamed('/posts');
                },
                child: Text(
                  "Create Account Later",
                  style: TextStyle(fontSize: 16),
                )
            ),


          ],
        ),
      ),
    );
  }
}


class LoginBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(LoginViewModel());
  }

}