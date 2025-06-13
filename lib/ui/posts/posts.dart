import 'package:agrisol/ui/posts/post_details.dart';
import 'package:agrisol/ui/posts/view_models/posts_vm.dart';
import 'package:agrisol/ui/saved_posts/saved_posts.dart';
import 'package:agrisol/ui/saved_posts/view_models/saved_posts_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/AuthRepository.dart';
import '../../data/PostRepository.dart';
import '../../data/user_repository.dart';
import '../../model/post.dart';
import '../profile/profile_page.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  int _selectedIndex = 0;
  late final postsViewModel = Get.find<PostsViewModel>();
  late final authRepository = Get.find<AuthRepository>();
  late final savedPostsViewModel = Get.find<SavedPostsViewModel>();

  @override
  void initState() {
    super.initState();
    final email = authRepository.getLoggedInUser()?.email;
  }

  Future<void> _logout() async {
    authRepository.logout();
    Get.offAllNamed('/login');
  }

  Widget _buildAuthorLikedComment(Post post) {
    final comments = post.comments ?? [];
    final authorLikedId = post.authorLikedCommentId;
    final likedComment = authorLikedId != null
        ? comments.firstWhereOrNull((c) => c.id == authorLikedId)
        : null;

    if (likedComment == null) {
      return const Text("No accepted comment yet.",
          style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic));
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.09),
        border: Border.all(color: Colors.green.withOpacity(0.20)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  likedComment.content,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 15),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  "by @${likedComment.authorUsername}",
                  style: TextStyle(fontSize: 12.2, color: Colors.grey[600]),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Icon(Icons.check_circle, color: Colors.green[600], size: 20),
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post) {
    final currentUser = authRepository.getLoggedInUser();
    final isMyPost = post.uId == currentUser?.uid;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
        border: Border.all(color: Colors.grey.withOpacity(0.12)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          children: [
            ListTile(
              contentPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 10),
              minLeadingWidth: 0,
              leading: post.image == null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  color: Colors.grey[200],
                  width: 44,
                  height: 44,
                  child: const Icon(Icons.image, size: 30, color: Colors.grey),
                ),
              )
                  : ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(post.image!,
                    height: 44, width: 44, fit: BoxFit.cover),
              ),
              title: Text(
                post.title,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      post.description,
                      style: const TextStyle(fontSize: 13.5),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            isMyPost
                                ? 'Posted by you (@${post.authorUsername})'
                                : 'Posted by @${post.authorUsername}',
                            style: TextStyle(
                              fontSize: 11.8,
                              color: isMyPost
                                  ? Colors.green[600]
                                  : Colors.blueGrey[500],
                              fontStyle: FontStyle.italic,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (post.category != null) ...[
                          const SizedBox(width: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 1, horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(7),
                            ),
                            child: Text("${post.category}",
                                style: const TextStyle(
                                    fontSize: 10.5, color: Colors.blueGrey)),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              tileColor: isMyPost ? Colors.grey[100] : null,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
              child: _buildAuthorLikedComment(post),
            ),
            // WRAP THIS ROW IN SINGLECHILDSCROLLVIEW TO PREVENT OVERFLOW ON SMALL WIDTHS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Material(
                      color: Colors.green.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(24),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(24),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => PostDetailsPage(postId: post.id),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.comment, color: Colors.green, size: 18),
                              SizedBox(width: 4),
                              Text(
                                "View Post Details/Comments",
                                style: TextStyle(color: Colors.green, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (isMyPost) ...[
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange, size: 22),
                        tooltip: "Edit Post",
                        onPressed: () => Get.toNamed('/addPost', arguments: post),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red, size: 22),
                        tooltip: "Delete Post",
                        onPressed: () => postsViewModel.deletePost(post),
                      ),
                    ],
                    Obx(() => IconButton(
                      icon: Icon(
                        savedPostsViewModel.isPostSaved(post)
                            ? Icons.bookmark
                            : Icons.bookmark_border,
                        color: savedPostsViewModel.isPostSaved(post)
                            ? Colors.blue
                            : Colors.grey,
                        size: 22,
                      ),
                      tooltip: savedPostsViewModel.isPostSaved(post)
                          ? "Unsave Post"
                          : "Save Post",
                      onPressed: () async {
                        await savedPostsViewModel.toggleSave(post);
                        Get.snackbar(
                          savedPostsViewModel.isPostSaved(post) ? "Saved" : "Unsaved",
                          savedPostsViewModel.isPostSaved(post)
                              ? "Post saved"
                              : "Post removed",
                        );
                      },
                    )),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsList(List<Post> postsList) {
    return postsList.isEmpty
        ? const Center(child: Text("No posts available."))
        : ListView.builder(
      itemCount: postsList.length,
      itemBuilder: (context, index) => _buildPostItem(postsList[index]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = authRepository.getLoggedInUser();
    final allPostsTab = Obx(() => _buildPostsList(postsViewModel.posts));
    final myPostsTab = Obx(() => _buildPostsList(postsViewModel.posts
        .where((post) => post.uId == currentUser?.uid)
        .toList()));
    final savedPostsTab = SavedPostsScreen();
    final profileTab = const ProfilePage();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Welcome to Agri-Sol!"),
        centerTitle: true,
        elevation: 0.5,
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
          if (result == true)
            Get.snackbar("Post Added", "Post Added Successfully");
        },
        child: const Icon(Icons.add),
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            allPostsTab,
            myPostsTab,
            savedPostsTab,
            profileTab,
          ],
        ),
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.green[50],
          primaryColor: Colors.green[700],
          textTheme: Theme.of(context)
              .textTheme
              .copyWith(bodySmall: const TextStyle(color: Colors.green)),
          splashColor: Colors.green[100],
          highlightColor: Colors.green[100],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.green[50],
          selectedItemColor: Colors.green[800],
          unselectedItemColor: Colors.green[300],
          selectedIconTheme:
          const IconThemeData(color: Colors.green, size: 28),
          unselectedIconTheme:
          const IconThemeData(color: Color(0xFF81C784)),
          onTap: (i) {
            setState(() => _selectedIndex = i);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(
                icon: Icon(Icons.person), label: 'My Posts'),
            BottomNavigationBarItem(
                icon: Icon(Icons.bookmark), label: 'Saved Posts'),
            BottomNavigationBarItem(
                icon: Icon(Icons.account_circle), label: 'Profile'),
          ],
        ),
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
    Get.put(SavedPostsViewModel());
    Get.put(UserRepository());
  }
}