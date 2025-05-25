
import 'package:agrisol/data/AuthRepository.dart';
import 'package:agrisol/data/PostRepository.dart';
import 'package:agrisol/model/post.dart';
import 'package:get/get.dart';

class AddPostViewModel extends GetxController{
  AuthRepository authRepository = Get.find();
  PostsRepository postsRepository = Get.find();
  var isSaving = false.obs;

  Future<void> addPost(String title, String description, Post? post) async {

    if(title.isEmpty){
      Get.snackbar("Error", "Enter valid Title");
      return;
    }

    if(description.isEmpty){
      Get.snackbar("Error", "Enter Description");
      return;
    }

    isSaving.value = true;

    if(post == null) {
      Post post = Post(
          '',
          authRepository
              .getLoggedInUser()
              ?.uid ?? '',
          title,
          description
      );
      try {
        await postsRepository.addPost(post);
        Get.back(result: true);
      } catch (e) {
        Get.snackbar("Error", "An unexpected error occurred ${e.toString()}");
      }
    }else
    {
      post.title = title;
      post.description = description;

      try {
        await postsRepository.updatePost(post);
        Get.back(result: true);
      } catch (e) {
        Get.snackbar("Error", "An unexpected error occurred ${e.toString()}");
      }
    }

    isSaving.value = false;
    }

}