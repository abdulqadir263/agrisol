import 'package:get/get.dart';
import '../../../data/AuthRepository.dart';
import '../../../data/PostRepository.dart';
import '../../../data/user_repository.dart';
import '../../../model/post.dart';
import '../../../model/comment.dart';

class PostsViewModel extends GetxController {
  AuthRepository authRepository = Get.find();
  PostsRepository postsRepository = Get.find();
  UserRepository userRepository = Get.find();
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

  Future<void> addComment(
      Post post,
      String content, {
        String? authorUid,
        String? authorUsername,
      }) async {
    final currentUser = authRepository.getLoggedInUser();
    final uid = authorUid ?? currentUser?.uid;
    if (uid == null) {
      Get.snackbar("Error", "You must be logged in to comment");
      return;
    }
    if (content.trim().isEmpty) {
      Get.snackbar("Error", "Comment cannot be empty");
      return;
    }

    String? username = authorUsername;
    if (username == null) {
      final appUser = await userRepository.getUserByUid(uid);
      username = appUser?.username ?? 'user';
    }

    final comment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorUid: uid,
      authorUsername: username,
      content: content,
      timestamp: DateTime.now(),
      likedBy: [],
    );
    await postsRepository.addCommentToPost(post, comment);
  }

  void likeComment(Post post, Comment comment) {
    final userUid = authRepository.getLoggedInUser()?.uid ?? "";
    if (comment.likedBy.contains(userUid)) return;
    for (var c in post.comments ?? []) {
      c.likedBy.remove(userUid);
    }
    comment.likedBy.add(userUid);
    postsRepository.updateCommentLikeStatus(post, comment);
    update();
  }

  void unlikeComment(Post post, Comment comment) {
    final userUid = authRepository.getLoggedInUser()?.uid ?? "";
    comment.likedBy.remove(userUid);
    postsRepository.updateCommentLikeStatus(post, comment);
    update();
  }
}