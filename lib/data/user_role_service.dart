import 'package:get/get.dart';
import '../constants.dart';

class UserRoleService extends GetxService {
  final RxBool isAdmin = false.obs;

  void setRole(String email) {
    isAdmin.value = (email == adminEmail);
  }
}