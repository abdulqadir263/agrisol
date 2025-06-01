import 'package:agrisol/ui/saved_posts/view_models/saved_posts_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavedPostsScreen extends StatelessWidget {
  SavedPostsScreen({super.key});
  final SavedPostsViewModel vm = Get.put(SavedPostsViewModel());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Posts')),
      body: Obx(() {
        if (vm.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (vm.savedPosts.isEmpty) {
          return const Center(child: Text('No saved posts.'));
        }
        return ListView.builder(
          itemCount: vm.savedPosts.length,
          itemBuilder: (context, i) {
            final post = vm.savedPosts[i];
            return Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: post.image == null
                    ? const Icon(Icons.image)
                    : Image.network(post.image!, width: 50, height: 50),
                title: Text(post.title),
                subtitle: Text(post.description),
                trailing: IconButton(
                  icon: Icon(Icons.bookmark, color: Colors.blue),
                  onPressed: () => vm.toggleSave(post),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}