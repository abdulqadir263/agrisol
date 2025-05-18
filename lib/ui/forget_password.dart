import 'package:agrisol/ui/auth/view_models/reset_password_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/AuthRepository.dart';

class ResetPasswordPage extends StatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  late TextEditingController emailController;
  late ResetPasswordViewModel resetViewModel;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController(text:  Get.arguments);
    resetViewModel = Get.find();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Reset Password"),

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

            Obx(() {
              return resetViewModel.isLoading.value
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: () {
                  resetViewModel.reset(
                    emailController.text,
                  );
                },
                child: const Text(
                  "RESET",
                  style: TextStyle(fontSize: 13),
                ),
              );
            }
            ),

            const SizedBox(height: 15),

            TextButton(
                onPressed: () {
                  Get.back();
                },
                child: Text(
                  "Back",
                  style: TextStyle(fontSize: 16),
                )
            )

          ],
        ),
      ),
    );
  }
}


class ResetPasswordBinding extends Bindings{
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(ResetPasswordViewModel());
  }

}