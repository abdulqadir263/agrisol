import 'package:agrisol/ui/posts/view_models/posts_vm.dart';
import 'package:agrisol/ui/saved_posts/view_models/saved_posts_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/AuthRepository.dart';
import '../../data/PostRepository.dart';
import '../../data/user_role_service.dart';
import '../../model/post.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  late PostsViewModel postsViewModel;
  late AuthRepository authRepository;
  late UserRoleService userRoleService;
  late SavedPostsViewModel savedPostsViewModel;
  final TextEditingController commentController = TextEditingController();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    postsViewModel = Get.find();
    authRepository = Get.find();
    userRoleService = Get.find();
    savedPostsViewModel = Get.find();

    final email = authRepository.getLoggedInUser()?.email;
    if (email != null) {
      userRoleService.setRole(email);
    }
    // For save/unsave icon button to reflect state immediately
    postsViewModel.loadAllPosts();
  }

  Future<void> _logout() async {
    authRepository.logout();
    Get.offAllNamed('/login');
  }

  Widget _buildCommentsSection(Post post) {
    final comments = post.comments ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...comments.map((c) => ListTile(
          title: Text(c.content),
          subtitle: Text("By Admin"),
        )),
        Obx(() => userRoleService.isAdmin.value
            ? Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: "Add comment (only admin can add comments)",
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                if (commentController.text.trim().isNotEmpty) {
                  postsViewModel.addComment(
                      post, commentController.text.trim());
                  commentController.clear();
                }
              },
            )
          ],
        )
            : const SizedBox.shrink()),
      ],
    );
  }

  Widget _buildPostItem(Post post) {
    final isMyPost = post.uId == authRepository.getLoggedInUser()?.uid;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            leading: post.image == null
                ? const Icon(Icons.image, size: 60)
                : Image.network(post.image!, height: 60, width: 60),
            title: Text(post.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.description),
                const SizedBox(height: 4),
                Text(
                  isMyPost ? 'Posted by you' : 'Posted by others',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.greenAccent[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                if (post.category != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      "Category: ${post.category}",
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.blueGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
              ],
            ),
            tileColor: isMyPost ? Colors.grey[100] : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildCommentsSection(post),
          ),
          OverflowBar(
            alignment: MainAxisAlignment.end,
            children: [
              if (isMyPost)
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.orange),
                  onPressed: () {
                    Get.toNamed('/addPost', arguments: post);
                  },
                ),
              if (isMyPost)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    postsViewModel.deletePost(post);
                  },
                ),
              // SAVE/UNSAVE ICON BUTTON (Obx for reactive state)
              Obx(() => IconButton(
                icon: Icon(
                  savedPostsViewModel.isPostSaved(post)
                      ? Icons.bookmark
                      : Icons.bookmark_border,
                  color: savedPostsViewModel.isPostSaved(post)
                      ? Colors.blue
                      : Colors.grey,
                ),
                onPressed: () async {
                  await savedPostsViewModel.toggleSave(post);
                  Get.snackbar(
                    savedPostsViewModel.isPostSaved(post)
                        ? "Saved"
                        : "Unsaved",
                    savedPostsViewModel.isPostSaved(post)
                        ? "Post saved"
                        : "Post removed",
                  );
                },
                tooltip: savedPostsViewModel.isPostSaved(post)
                    ? "Unsave Post"
                    : "Save Post",
              )),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Widget _buildPostsList(List<Post> postsList) {
    if (postsList.isEmpty) {
      return const Center(child: Text("No posts available."));
    }
    return ListView.builder(
      itemCount: postsList.length,
      itemBuilder: (context, index) {
        return _buildPostItem(postsList[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final allPostsTab = Obx(() => _buildPostsList(postsViewModel.posts));
    final myPostsTab = Obx(() {
      final myPosts = postsViewModel.posts
          .where((post) => post.uId == authRepository.getLoggedInUser()?.uid)
          .toList();
      return _buildPostsList(myPosts);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Agri-Sol!"),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Logout',
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var result = await Get.toNamed('/addPost');
          if (result == true) {
            Get.snackbar("Post Added", "Post Added Successfully");
          }
        },
        child: const Icon(Icons.add),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          allPostsTab,
          myPostsTab,
          // Placeholder for SavedPosts tab
          Container(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (i) async {
          if (i == 2) {
            // Go to SavedPostsScreen on Saved Posts tab tap
            await Get.toNamed('/savedPosts');
            // Optionally reset tab to previous after returning
            setState(() {
              _selectedIndex = 0;
            });
            return;
          }
          setState(() {
            _selectedIndex = i;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'My Posts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Saved Posts',
          ),
        ],
      ),
    );
  }
}

class PostsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AuthRepository());
    Get.put(PostsRepository());
    Get.put(PostsViewModel());
    Get.put(UserRoleService());
    Get.put(SavedPostsViewModel());
  }
}