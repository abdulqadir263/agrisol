import 'package:agrisol/ui/posts/view_models/posts_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../constants.dart';
import '../../data/AuthRepository.dart';
import '../../data/PostRepository.dart';
import '../../data/user_role_service.dart';
import '../../model/post.dart';
import '../../model/comment.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> with SingleTickerProviderStateMixin {
  late PostsViewModel postsViewModel;
  late AuthRepository authRepository;
  late TabController _tabController;
  late UserRoleService userRoleService;
  final TextEditingController commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    postsViewModel = Get.find();
    authRepository = Get.find();
    userRoleService = Get.find();
    _tabController = TabController(length: 2, vsync: this);

    // Set admin role on login
    final email = authRepository.getLoggedInUser()?.email;
    if (email != null) {
      userRoleService.setRole(email);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
          subtitle: Text("By: ${c.authorEmail}"),
        )),
        Obx(() => userRoleService.isAdmin.value
            ? Row(
          children: [
            Expanded(
              child: TextField(
                controller: commentController,
                decoration: const InputDecoration(
                  hintText: "Add comment (admin only)",
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: () {
                if (commentController.text.trim().isNotEmpty) {
                  postsViewModel.addComment(post, commentController.text.trim());
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
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          ListTile(
            onTap: () {
              if (post.uId == authRepository.getLoggedInUser()?.uid) {
                Get.dialog(AlertDialog(
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton(
                        child: const Text('Edit'),
                        onPressed: () {
                          Get.back();
                          Get.toNamed('/addPost', arguments: post);
                        },
                      ),
                      TextButton(
                        child: const Text('Delete'),
                        onPressed: () {
                          postsViewModel.deletePost(post);
                          Get.back();
                        },
                      ),
                    ],
                  ),
                ));
              }
            },
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
                  post.uId == authRepository.getLoggedInUser()?.uid
                      ? 'Posted by you'
                      : 'Posted by others',
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
            tileColor: post.uId == authRepository.getLoggedInUser()?.uid
                ? Colors.grey[100]
                : null,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: _buildCommentsSection(post),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Agri-Sol!"),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'All Posts'),
            Tab(text: 'My Posts'),
          ],
        ),
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
      body: Obx(() {
        final myPosts = postsViewModel.posts
            .where((post) => post.uId == authRepository.getLoggedInUser()?.uid)
            .toList();

        return TabBarView(
          controller: _tabController,
          children: [
            // All Posts Tab
            ListView.builder(
              itemCount: postsViewModel.posts.length,
              itemBuilder: (context, index) {
                return _buildPostItem(postsViewModel.posts[index]);
              },
            ),
            // My Posts Tab
            ListView.builder(
              itemCount: myPosts.length,
              itemBuilder: (context, index) {
                return _buildPostItem(myPosts[index]);
              },
            ),
          ],
        );
      }),
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
  }
}