import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../data/AuthRepository.dart';
import '../../../data/PostRepository.dart';
import '../../../data/media_repo.dart';
import '../../../data/user_repository.dart';
import '../../../model/post.dart';

class AddPostViewModel extends GetxController {
  AuthRepository authRepository = Get.find();
  PostsRepository postsRepository = Get.find();
  MediaRepository mediaRepository = Get.find();
  UserRepository userRepository = Get.find();
  var isSaving = false.obs;

  Rxn<XFile> image = Rxn<XFile>();

  Future<void> addPost(String title, String description, Post? post, {String? category}) async {
    if (title.isEmpty) {
      Get.snackbar("Error", "Enter valid Title");
      return;
    }

    if (description.isEmpty) {
      Get.snackbar("Error", "Enter Description");
      return;
    }

    isSaving.value = true;

    final currentUser = authRepository.getLoggedInUser();
    final uid = currentUser?.uid ?? '';
    final appUser = await userRepository.getUserByUid(uid);
    final authorUsername = appUser?.username ?? 'user';

    if (post == null) {
      Post newPost = Post(
        '',
        uid,
        authorUsername,
        title,
        description,
        category: category,
      );

      await uploadImage(newPost);

      try {
        await postsRepository.addPost(newPost);
        Get.back(result: true);
      } catch (e) {
        Get.snackbar("Error", "An unexpected error occurred ${e.toString()}");
      }
    } else {
      post.title = title;
      post.description = description;
      post.category = category;
      post.authorUsername = authorUsername; // update username if changed

      try {
        await uploadImage(post);
        await postsRepository.updatePost(post);
        Get.back(result: true);
      } catch (e) {
        Get.snackbar("Error", "An unexpected error occurred ${e.toString()}");
      }
    }

    isSaving.value = false;
  }

  Future<void> uploadImage(Post post) async {
    if (image.value != null) {
      var imageResult = await mediaRepository.uploadImg(image.value!.path);
      if (imageResult.isSuccessful) {
        post.image = imageResult.url;
      } else {
        Get.snackbar('Error Uploading Image', imageResult.error ?? "Couldn't upload image due to some error");
        return;
      }
    }
  }

  Future<void> pickImage() async {
    final ImagePicker picker = ImagePicker();
    image.value = await picker.pickImage(source: ImageSource.gallery);
  }
}