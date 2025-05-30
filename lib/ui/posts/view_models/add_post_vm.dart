
import 'package:agrisol/data/AuthRepository.dart';
import 'package:agrisol/data/PostRepository.dart';
import 'package:agrisol/data/media_repo.dart';
import 'package:agrisol/model/post.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class AddPostViewModel extends GetxController{
  AuthRepository authRepository = Get.find();
  PostsRepository postsRepository = Get.find();
  MediaRepository mediaRepository = Get.find();
  var isSaving = false.obs;

  Rxn<XFile> image = Rxn<XFile>();

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

      await uploadImage(post);
      
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
      if(image.value!=null) {
        var imageResult = await mediaRepository.uploadImg(image.value!.path);
        if(imageResult.isSuccessful){
          post.image = imageResult.url;
        }else
        {
          Get.snackbar('Error Uploading Image',
              imageResult.error??"Couldn't upload image due to some error"
          );
          return;
        }
      }
    }


    Future<void> pickImage() async {
      final ImagePicker picker = ImagePicker();
      image.value = await picker.pickImage(source: ImageSource.gallery);
    }

}