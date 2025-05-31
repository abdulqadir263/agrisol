import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../data/AuthRepository.dart';
import '../../data/user_role_service.dart';
import 'view_models/signup_vm.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool signupAsAdmin = false;
  late SignUpViewModel signUpViewModel;

  @override
  void initState() {
    super.initState();
    signUpViewModel = Get.find();

    if (signUpViewModel.isUserLoggedIn()) {
      Get.offAllNamed('/posts');
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
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                hintText: "Enter your email",
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),
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
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              obscureText: _obscurePassword,
              controller: confirmPasswordController,
              decoration: InputDecoration(
                labelText: "Confirm Password",
                hintText: "Confirm your password",
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
                contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: signupAsAdmin,
                  onChanged: (v) {
                    setState(() {
                      signupAsAdmin = v!;
                    });
                  },
                ),
                const Text("Signup as Admin"),
              ],
            ),
            const SizedBox(height: 30),
            Obx(() {
              return signUpViewModel.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  if (signupAsAdmin && emailController.text != adminEmail) {
                    Get.snackbar("Error", "Only $adminEmail can signup as Admin");
                    return;
                  }
                  Get.find<UserRoleService>().setRole(emailController.text);
                  signUpViewModel.signup(
                    emailController.text,
                    passwordController.text,
                    confirmPasswordController.text,
                  );
                },
                child: const Text(
                  "SIGNUP",
                  style: TextStyle(fontSize: 16),
                ),
              );
            }),
            const SizedBox(height: 15),
            TextButton(
              onPressed: () {
                Get.offAllNamed('/login');
              },
              child: const Text(
                "Already have account; Login",
                style: TextStyle(fontSize: 16),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(SignUpViewModel());
    Get.put(UserRoleService());
  }
}