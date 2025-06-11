import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/user_repository.dart';
import '../../model/user.dart';

class ProfileViewModel extends GetxController {
  final UserRepository repo = Get.find<UserRepository>();
  var isLoading = false.obs;
  var appUser = Rxn<AppUser>();

  Future<void> loadProfile() async {
    isLoading.value = true;
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final loadedUser = await repo.getUserByUid(user.uid);
      appUser.value = loadedUser;
    }
    isLoading.value = false;
  }

  Future<bool> updateProfile(String username, String? contact, String? location) async {
    isLoading.value = true;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      isLoading.value = false;
      return false;
    }
    if (await repo.isUsernameTaken(username) &&
        (await repo.getUserByUid(user.uid))?.username != username) {
      isLoading.value = false;
      return false;
    }
    await repo.updateUserProfile(user.uid, username, contact, location);
    await loadProfile();
    isLoading.value = false;
    return true;
  }
}