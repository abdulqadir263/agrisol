import 'package:agrisol/ui/saved_posts/view_models/saved_posts_vm.dart';
import 'package:agrisol/ui/posts/post_details.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SavedPostsScreen extends StatelessWidget {
  const SavedPostsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SavedPostsViewModel vm = Get.find<SavedPostsViewModel>();
    return Obx(() {
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
              onTap: () {
                // Navigate to PostDetailsPage for this post
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PostDetailsPage(postId: post.id),
                  ),
                );
              },
              leading: post.image == null
                  ? const Icon(Icons.image)
                  : Image.network(post.image!, width: 50, height: 50, fit: BoxFit.cover),
              title: Text(
                post.title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                post.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: IconButton(
                icon: const Icon(Icons.bookmark, color: Colors.blue),
                tooltip: "Remove from saved",
                onPressed: () => vm.toggleSave(post),
              ),
            ),
          );
        },
      );
    });
  }
}