import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class PostRepository {
  final FirebaseFirestore _firestore;

  PostRepository() : _firestore = FirebaseFirestore.instance;

  Future<void> addPost({
    required String userId,
    required String userName,
    required String title,
    required String description,
    required String category,
  }) async {
    try {
      await _firestore.collection('posts').add({
        'userId': userId,
        'userName': userName,
        'title': title,
        'description': description,
        'category': category,
        'createdAt': FieldValue.serverTimestamp(),
        'likes': 0,
        'comments': [],
      });
    } catch (e) {
      debugPrint('Error adding post: $e');
      rethrow;
    }
  }

  Stream<QuerySnapshot> getPostsStream() {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }


  Future<List<DocumentSnapshot>> getPosts() async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .get();
      return querySnapshot.docs;
    } catch (e) {
      debugPrint('Error getting posts: $e');
      rethrow;
    }
  }
}