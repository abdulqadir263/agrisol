import 'package:get/get.dart';
import '../../../data/AuthRepository.dart';
import '../../../data/PostRepository.dart';
import '../../../model/post.dart';
import '../../../model/comment.dart';
import '../../../constants.dart';

class PostsViewModel extends GetxController {
  AuthRepository authRepository = Get.find();
  PostsRepository postsRepository = Get.find();
  var isLoading = false.obs;
  var posts = <Post>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadAllPosts();
  }

  void loadAllPosts() {
    postsRepository.loadAllPosts().listen((data) {
      posts.value = data;
    });
  }

  void deletePost(Post post) {
    final currentUser = authRepository.getLoggedInUser();
    if (currentUser != null && post.uId == currentUser.uid) {
      postsRepository.deletePost(post);
    } else {
      Get.snackbar("Error", "You can only delete your own posts");
    }
  }

  void addComment(Post post, String content) {
    final currentUser = authRepository.getLoggedInUser();
    if (currentUser == null || currentUser.email != adminEmail) {
      Get.snackbar("Error", "Only admin can add comments");
      return;
    }
    if (content.trim().isEmpty) {
      Get.snackbar("Error", "Comment cannot be empty");
      return;
    }
    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorEmail: currentUser.email ?? "",
      content: content,
    );
    postsRepository.addCommentToPost(post, comment);
  }
}