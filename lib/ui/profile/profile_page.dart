import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/user_repository.dart';
import '../../ui/profile/profile_vm.dart';

class ProfilePage extends StatefulWidget {
  final bool isFirstTime;
  const ProfilePage({this.isFirstTime = false, Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController usernameController;
  late TextEditingController contactController;
  late TextEditingController locationController;
  final _formKey = GlobalKey<FormState>();
  final ProfileViewModel profileVM = Get.put(ProfileViewModel());
  bool loading = false;
  String? userEmail;
  String? uid;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    userEmail = user?.email ?? "";
    uid = user?.uid ?? "";
    usernameController = TextEditingController();
    contactController = TextEditingController();
    locationController = TextEditingController();
    _loadUser();
  }

  Future<void> _loadUser() async {
    setState(() => loading = true);
    await profileVM.loadProfile();
    if (profileVM.appUser.value != null) {
      usernameController.text = profileVM.appUser.value?.username ?? "";
      contactController.text = profileVM.appUser.value?.contact ?? "";
      locationController.text = profileVM.appUser.value?.location ?? "";
    }
    setState(() => loading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => loading = true);
    final success = await profileVM.updateProfile(
      usernameController.text.trim(),
      contactController.text.trim(),
      locationController.text.trim(),
    );
    setState(() => loading = false);
    if (!success) {
      Get.snackbar("Username taken", "Please choose another username");
      return;
    }
    if (widget.isFirstTime) {
      Get.offAllNamed('/posts');
    } else {
      if (Navigator.canPop(context)) {
        Navigator.pop(context, true); // return to previous page if available
      }
      Get.snackbar("Profile updated", "Your profile has been updated");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 400),
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text(
                    "Profile Details",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall
                        ?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    enabled: false,
                    initialValue: userEmail ?? "",
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: usernameController,
                    decoration: const InputDecoration(
                      labelText: "Username",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return "Username is required";
                      }
                      if (val.length < 3) {
                        return "Username too short";
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: contactController,
                    decoration: const InputDecoration(
                      labelText: "Contact",
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 15),
                  TextFormField(
                    controller: locationController,
                    decoration: const InputDecoration(
                      labelText: "Location",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: loading ? null : _saveProfile,
                    child: Text(widget.isFirstTime
                        ? "Complete Profile"
                        : "Update Profile"),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}