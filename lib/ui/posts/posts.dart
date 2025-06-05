import 'package:agrisol/ui/posts/view_models/posts_vm.dart';
import 'package:agrisol/ui/saved_posts/view_models/saved_posts_vm.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/AuthRepository.dart';
import '../../data/PostRepository.dart';
import '../../data/user_role_service.dart';
import '../../data/user_repository.dart';
import '../../model/post.dart';
import '../profile/profile_page.dart';

class PostsPage extends StatefulWidget {
  const PostsPage({super.key});

  @override
  State<PostsPage> createState() => _PostsPageState();
}

class _PostsPageState extends State<PostsPage> {
  final _commentControllers = <String, TextEditingController>{};
  int _selectedIndex = 0;
  late final postsViewModel = Get.find<PostsViewModel>();
  late final authRepository = Get.find<AuthRepository>();
  late final userRoleService = Get.find<UserRoleService>();
  late final savedPostsViewModel = Get.find<SavedPostsViewModel>();

  @override
  void initState() {
    super.initState();
    final email = authRepository.getLoggedInUser()?.email;
    if (email != null) userRoleService.setRole(email);
    postsViewModel.loadAllPosts();
  }

  Future<void> _logout() async {
    authRepository.logout();
    Get.offAllNamed('/login');
  }

  Widget _buildCommentsSection(Post post) {
    final comments = post.comments ?? [];
    final controller = _commentControllers.putIfAbsent(post.id, () => TextEditingController());
    final currentUser = authRepository.getLoggedInUser();
    final userUid = currentUser?.uid ?? "";
    final likedComment = comments.firstWhereOrNull((c) => c.likedBy.contains(userUid));
    final isPostAuthor = post.uId == userUid;

    final displayComments = likedComment != null
        ? [likedComment, ...comments.where((c) => c.id != likedComment.id)]
        : comments;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (displayComments.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 6, left: 2),
              child: Text("Comments", style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
                fontSize: 15,
              )),
            ),
          ...displayComments.map((c) => Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            decoration: BoxDecoration(
              color: c == likedComment ? Colors.blue.withOpacity(0.08) : Colors.grey.withOpacity(0.07),
              border: Border.all(color: c == likedComment ? Colors.blue.withOpacity(0.2) : Colors.grey.withOpacity(0.15)),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.comment, color: Colors.grey[500], size: 20),
                const SizedBox(width: 8),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(c.content, style: TextStyle(
                      fontWeight: c == likedComment ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 15.5,
                    )),
                    const SizedBox(height: 3),
                    Text("by @${c.authorUsername}", style: TextStyle(
                      fontSize: 12.4,
                      color: Colors.grey[600],
                    )),
                  ],
                )),
                if (isPostAuthor && likedComment == null || c.id == likedComment?.id)
                  IconButton(
                    icon: Icon(
                      c.id == likedComment?.id ? Icons.thumb_up : Icons.thumb_up_alt_outlined,
                      color: c.id == likedComment?.id ? Colors.blue : null,
                      size: 20,
                    ),
                    tooltip: c.id == likedComment?.id ? "Unlike this comment" : "Like this comment",
                    onPressed: () => c.id == likedComment?.id
                        ? postsViewModel.unlikeComment(post, c)
                        : postsViewModel.likeComment(post, c),
                  ),
              ],
            ),
          )),
          if (currentUser != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: [
                  Expanded(child: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: "Add a comment",
                      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(9),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  )),
                  const SizedBox(width: 7),
                  Material(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () async {
                        if (controller.text.trim().isNotEmpty) {
                          final userRepo = Get.find<UserRepository>();
                          final appUser = await userRepo.getUserByUid(userUid);
                          postsViewModel.addComment(
                            post,
                            controller.text.trim(),
                            authorUid: userUid,
                            authorUsername: appUser?.username ?? 'user',
                          );
                          controller.clear();
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                        child: Icon(Icons.send, color: Colors.blue[700], size: 22),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostItem(Post post) {
    final currentUser = authRepository.getLoggedInUser();
    final isMyPost = post.uId == currentUser?.uid;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(
          color: Colors.grey.withOpacity(0.08),
          spreadRadius: 1,
          blurRadius: 8,
          offset: const Offset(0, 2),
        )],
        border: Border.all(color: Colors.grey.withOpacity(0.13)),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
            leading: post.image == null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                color: Colors.grey[200],
                width: 55,
                height: 55,
                child: const Icon(Icons.image, size: 36, color: Colors.grey),
              ),
            )
                : ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(post.image!, height: 55, width: 55, fit: BoxFit.cover),
            ),
            title: Text(post.title, style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17,
            )),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post.description, style: const TextStyle(fontSize: 14.8)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Text(
                        isMyPost ? 'Posted by you (@${post.authorUsername})' : 'Posted by @${post.authorUsername}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isMyPost ? Colors.green[600] : Colors.blueGrey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      if (post.category != null) ...[
                        const SizedBox(width: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 7),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(7),
                          ),
                          child: Text("${post.category}", style: const TextStyle(
                              fontSize: 11.8, color: Colors.blueGrey),
                          ),
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: _buildCommentsSection(post),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: OverflowBar(
              alignment: MainAxisAlignment.end,
              spacing: 0,
              children: [
                if (isMyPost) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.orange),
                    tooltip: "Edit Post",
                    onPressed: () => Get.toNamed('/addPost', arguments: post),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: "Delete Post",
                    onPressed: () => postsViewModel.deletePost(post),
                  ),
                ],
                Obx(() => IconButton(
                  icon: Icon(
                    savedPostsViewModel.isPostSaved(post) ? Icons.bookmark : Icons.bookmark_border,
                    color: savedPostsViewModel.isPostSaved(post) ? Colors.blue : Colors.grey,
                  ),
                  tooltip: savedPostsViewModel.isPostSaved(post) ? "Unsave Post" : "Save Post",
                  onPressed: () async {
                    await savedPostsViewModel.toggleSave(post);
                    Get.snackbar(
                      savedPostsViewModel.isPostSaved(post) ? "Saved" : "Unsaved",
                      savedPostsViewModel.isPostSaved(post) ? "Post saved" : "Post removed",
                    );
                  },
                )),
              ],
            ),
          ),
          const SizedBox(height: 4),
        ],
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
    final myPostsTab = Obx(() => _buildPostsList(
        postsViewModel.posts.where((post) => post.uId == currentUser?.uid).toList()
    ));

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
          if (result == true) Get.snackbar("Post Added", "Post Added Successfully");
        },
        child: const Icon(Icons.add),
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [allPostsTab, myPostsTab, Container(), ProfilePage()],
      ),
      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          canvasColor: Colors.green[50],
          primaryColor: Colors.green[700],
          textTheme: Theme.of(context).textTheme.copyWith(
            bodySmall: const TextStyle(color: Colors.green),
          ),
          splashColor: Colors.green[100],
          highlightColor: Colors.green[100],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.green[50],
          selectedItemColor: Colors.green[800],
          unselectedItemColor: Colors.green[300],
          selectedIconTheme: const IconThemeData(color: Colors.green, size: 28),
          unselectedIconTheme: const IconThemeData(color: Color(0xFF81C784)),
          onTap: (i) async {
            if (i == 2) {
              await Get.toNamed('/savedPosts');
              setState(() => _selectedIndex = 0);
              return;
            }
            setState(() => _selectedIndex = i);
          },
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'My Posts'),
            BottomNavigationBarItem(icon: Icon(Icons.bookmark), label: 'Saved Posts'),
            BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
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
    Get.put(UserRoleService());
    Get.put(SavedPostsViewModel());
    Get.put(UserRepository());
  }
}