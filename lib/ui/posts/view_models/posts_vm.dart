
import 'package:get/get.dart';

import '../../../data/AuthRepository.dart';
import '../../../data/PostRepository.dart';
import '../../../model/post.dart';

class PostsViewModel extends GetxController{

  AuthRepository authRepository = Get.find();
  PostsRepository postsRepository = Get.find();
  var isLoading = false.obs;
  var posts = <Post>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllPosts();
  }

  void loadAllPosts(){
    postsRepository.loadAllPosts().listen(
          (data) {
      posts.value = data;
    },
    );
  }

  void deletePost(Post post){
    final currentUser = authRepository.getLoggedInUser();
    if (currentUser != null && post.uId == currentUser.uid) {
      postsRepository.deletePost(post);
    } else {
      Get.snackbar("Error", "You can only delete your own posts");
    }
  }



}