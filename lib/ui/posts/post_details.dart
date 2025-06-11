import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../model/post.dart';
import '../../model/comment.dart';
import 'view_models/posts_vm.dart';
import '../../data/user_repository.dart';

class PostDetailsPage extends StatefulWidget {
  final String postId;
  const PostDetailsPage({super.key, required this.postId});

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  late final PostsViewModel postsViewModel;
  late final UserRepository userRepo;
  final TextEditingController _controller = TextEditingController();
  User? currentUser;
  String? currentUsername;

  @override
  void initState() {
    super.initState();
    postsViewModel = Get.find<PostsViewModel>();
    userRepo = Get.find<UserRepository>();
    currentUser = FirebaseAuth.instance.currentUser;
    _fetchUsername();
  }

  Future<void> _fetchUsername() async {
    if (currentUser != null) {
      final appUser = await userRepo.getUserByUid(currentUser!.uid);
      setState(() {
        currentUsername = appUser?.username;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final post = postsViewModel.posts.firstWhereOrNull((p) => p.id == widget.postId);

    if (post == null) {
      return Scaffold(
        appBar: AppBar(title: const Text("Post Details")),
        body: const Center(child: Text("Post not found.")),
      );
    }

    final comments = post.comments ?? [];
    final authorLikedId = post.authorLikedCommentId;
    final likedComment = authorLikedId != null
        ? comments.firstWhereOrNull((c) => c.id == authorLikedId)
        : null;
    final restComments = likedComment != null
        ? comments.where((c) => c.id != likedComment.id).toList()
        : comments;

    final isPostAuthor = post.uId == currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: const Text("Post Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            if (post.image != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(post.image!, height: 180, fit: BoxFit.cover),
              ),
            const SizedBox(height: 16),
            Text(post.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(post.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            if (post.category != null)
              Chip(label: Text(post.category!), backgroundColor: Colors.blue[50]),
            const Divider(height: 32),
            Text("Comments", style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (likedComment != null)
              _buildCommentTile(context, post, likedComment, isPostAuthor, accepted: true),
            ...restComments.map(
                  (c) => _buildCommentTile(context, post, c, isPostAuthor, accepted: false),
            ),
            const SizedBox(height: 20),
            _buildAddCommentBar(context, post),
          ],
        ),
      ),
    );
  }

  Widget _buildCommentTile(BuildContext context, Post post, Comment comment, bool isPostAuthor, {bool accepted = false}) {
    return Card(
      color: accepted ? Colors.green[50] : null,
      margin: const EdgeInsets.symmetric(vertical: 7),
      child: ListTile(
        leading: accepted
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.comment, color: Colors.grey),
        title: Text(
          comment.content,
          style: TextStyle(
            fontWeight: accepted ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Text("by @${comment.authorUsername}"),
        trailing: isPostAuthor
            ? IconButton(
          icon: accepted
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.check, color: Colors.grey),
          tooltip: accepted ? "Unaccept" : "Accept this comment",
          onPressed: () {
            if (accepted) {
              postsViewModel.unlikeComment(post, comment);
            } else {
              postsViewModel.likeComment(post, comment);
            }
            setState(() {}); // Refresh for immediate UI response
          },
        )
            : null,
      ),
    );
  }

  Widget _buildAddCommentBar(BuildContext context, Post post) {
    if (currentUser == null) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(
              hintText: "Add a comment",
              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(color: Colors.blue),
              ),
            ),
          ),
        ),
        const SizedBox(width: 7),
        Material(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
            onTap: () async {
              if (_controller.text.trim().isNotEmpty && currentUser != null) {
                final appUser = await userRepo.getUserByUid(currentUser!.uid);
                await postsViewModel.addComment(
                  post,
                  _controller.text.trim(),
                  authorUid: currentUser!.uid,
                  authorUsername: appUser?.username ?? 'user',
                );
                _controller.clear();
                FocusScope.of(context).unfocus();
                setState(() {}); // Refresh to show the new comment
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
              child: Icon(Icons.send, color: Colors.blue[700], size: 22),
            ),
          ),
        ),
      ],
    );
  }
}