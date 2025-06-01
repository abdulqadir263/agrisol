import 'package:get/get.dart';
import '../../../data/saved_posts_repository.dart';
import '../../../model/post.dart';

class SavedPostsViewModel extends GetxController {
  final SavedPostsRepository repo = SavedPostsRepository();
  var savedPosts = <Post>[].obs;
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSavedPosts();
  }

  Future<void> fetchSavedPosts() async {
    isLoading.value = true;
    savedPosts.value = await repo.getSavedPosts();
    isLoading.value = false;
  }

  Future<void> toggleSave(Post post) async {
    final isSaved = savedPosts.any((p) => p.id == post.id);
    if (isSaved) {
      await repo.unsavePost(post.id);
      savedPosts.removeWhere((p) => p.id == post.id);
    } else {
      await repo.savePost(post.id);
      savedPosts.add(post);
    }
    update();
  }

  bool isPostSaved(Post post) {
    return savedPosts.any((p) => p.id == post.id);
  }
}