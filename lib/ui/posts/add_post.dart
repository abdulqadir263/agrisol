import 'dart:io';
import 'package:agrisol/data/PostRepository.dart';
import 'package:agrisol/ui/posts/view_models/add_post_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../data/AuthRepository.dart';
import '../../data/media_repo.dart';
import '../../model/post.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  late AddPostViewModel addPostViewModel;
  Post? post;
  String selectedCategory = postCategories.first;

  @override
  void initState() {
    super.initState();
    addPostViewModel = Get.find();
    post = Get.arguments;
    if (post != null) {
      titleController = TextEditingController(text: post?.title);
      descriptionController = TextEditingController(text: post?.description);
      selectedCategory = post?.category ?? postCategories.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Add Post", style: TextStyle(fontSize: 20)),
              const SizedBox(height: 20),
              Obx(() {
                final image = addPostViewModel.image.value;
                if (image != null) {
                  return Image.file(
                    File(image.path),
                    width: 125,
                    height: 125,
                  );
                }
                return const Icon(Icons.image, size: 60);
              }),
              ElevatedButton(
                onPressed: () {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    addPostViewModel.pickImage();
                  });
                },
                child: const Text("Pick Image"),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
                items: postCategories
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: titleController,
                decoration: InputDecoration(
                  labelText: "Post Title",
                  hintText: "Enter your Post Title",
                  prefixIcon: const Icon(Icons.abc),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: "Post Description",
                  hintText: "Enter your Problem in detail here",
                  prefixIcon: const Icon(Icons.text_snippet),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding:
                  const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                ),
              ),
              const SizedBox(height: 30),
              Obx(() {
                return addPostViewModel.isSaving.value
                    ? const CircularProgressIndicator()
                    : ElevatedButton(
                  onPressed: () {
                    addPostViewModel.addPost(
                      titleController.text,
                      descriptionController.text,
                      post,
                      category: selectedCategory,
                    );
                  },
                  child: const Text(
                    "Add Post",
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class AddPostBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(PostsRepository());
    Get.put(MediaRepository());
    Get.put(AddPostViewModel());
  }
}