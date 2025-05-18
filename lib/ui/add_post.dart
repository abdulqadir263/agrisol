import 'package:agrisol/ui/home/home.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../data/PostRepository.dart';
import 'auth/view_models/add_post_vm.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({super.key});

  @override
  State<AddPostPage> createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  String _selectedCategory = 'Pest Problem'; // Default category
  final AddPostViewModel _addPostViewModel = Get.find();

  final List<String> _categories = [
    'Pest Problem',
    'Disease',
    'Soil Issue',
    'Irrigation',
    'Fertilizer',
    'Harvesting',
    'Other'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Agriculture Problem'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: "Problem Title",
                  hintText: "e.g., Aphids in my wheat crop",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                items: _categories.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCategory = newValue!;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Category",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                maxLines: 5,
                decoration: InputDecoration(
                  labelText: "Detailed Description",
                  hintText: "Describe your problem in detail...",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 30),
              Obx(() {
                return _addPostViewModel.isLoading.value
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                  onPressed: () {
                    _addPostViewModel.addPost(
                      _titleController.text,
                      _descriptionController.text,
                      _selectedCategory,
                    );
                  },
                  child: const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      "POST PROBLEM",
                      style: TextStyle(fontSize: 16),
                    ),
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
    Get.put(PostRepository());
    Get.put(AddPostViewModel());
  }
}