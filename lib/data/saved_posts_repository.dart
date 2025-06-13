import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/post.dart';
import 'PostRepository.dart';

class SavedPostsRepository {
  final _usersCollection = FirebaseFirestore.instance.collection('users');
  final PostsRepository postsRepository = PostsRepository();

  User? getLoggedInUser() {
    return FirebaseAuth.instance.currentUser;
  }

  Future<List<String>> getSavedPostIds() async {
    final user = getLoggedInUser();
    if (user == null) return [];
    final doc = await _usersCollection.doc(user.uid).get();
    if (doc.exists && doc['savedPosts'] != null) {
      return List<String>.from(doc['savedPosts']);
    }
    return [];
  }

  Future<List<Post>> getSavedPosts() async {
    List<String> savedIds = await getSavedPostIds();
    if (savedIds.isEmpty) return [];
    List<Post> savedPosts = [];
    for (int i = 0; i < savedIds.length; i += 10) {
      final batch = savedIds.skip(i).take(10).toList();
      final query = await FirebaseFirestore.instance
          .collection('posts')
          .where(FieldPath.documentId, whereIn: batch)
          .get();
      savedPosts.addAll(query.docs.map((doc) => Post.fromMap(doc.data())));
    }
    return savedPosts;
  }

  Future<void> savePost(String postId) async {
    final user = getLoggedInUser();
    if (user == null) return;
    await _usersCollection.doc(user.uid).set({
      'savedPosts': FieldValue.arrayUnion([postId])
    }, SetOptions(merge: true));
  }

  Future<void> unsavePost(String postId) async {
    final user = getLoggedInUser();
    if (user == null) return;
    await _usersCollection.doc(user.uid).set({
      'savedPosts': FieldValue.arrayRemove([postId])
    }, SetOptions(merge: true));
  }
}