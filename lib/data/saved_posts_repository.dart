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
    List<Post> allPosts = await postsRepository.loadAllPostsOnce();
    return allPosts.where((p) => savedIds.contains(p.id)).toList();
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