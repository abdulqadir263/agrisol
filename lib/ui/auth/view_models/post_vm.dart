import 'package:agrisol/data/PostRepository.dart';
import 'package:agrisol/models/post_models.dart';
import 'package:get/get.dart';

class PostsViewModel extends GetxController {
  final PostRepository _postRepository = Get.find();
  final RxList<Post> posts = <Post>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    isLoading.value = true;
    try {
      final postDocs = await _postRepository.getPosts();
      posts.assignAll(postDocs.map((doc) => Post.fromDocument(doc)).toList();
      } catch (e) {
        Get.snackbar('Error', 'Failed to load posts');
      } finally {
      isLoading.value = false;
    }
  }

  Stream<List<Post>> getPostsStream() {
    return _postRepository.getPostsStream().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => Post.fromDocument(doc)).toList();
    });
  }
}