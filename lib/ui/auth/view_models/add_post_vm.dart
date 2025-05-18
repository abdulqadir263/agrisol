import 'package:agrisol/data/AuthRepository.dart';
import 'package:agrisol/data/PostRepository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class AddPostViewModel extends GetxController {
  final AuthRepository authRepository = Get.find();
  final PostRepository postRepository = Get.find();
  var isLoading = false.obs;

  Future<void> addPost(String title, String description, String category) async {
    final user = authRepository.getLoggedInUser();
    if (user == null) {
      Get.snackbar("Error", "You must be logged in to post");
      return;
    }

    if (title.isEmpty || description.isEmpty || category.isEmpty) {
      Get.snackbar("Error", "All fields are required");
      return;
    }

    isLoading.value = true;
    try {
      await postRepository.addPost(
        userId: user.uid,
        userName: user.displayName ?? 'Anonymous',
        title: title,
        description: description,
        category: category,
      );
      Get.snackbar("Success", "Post added successfully");
      Get.back(); // Return to previous screen after successful post
    } catch (e) {
      Get.snackbar("Error", "Failed to add post: ${e.toString()}");
    } finally {
      isLoading.value = false;
    }
  }
}