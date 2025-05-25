
import 'package:agrisol/model/post.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PostsRepository{

  late CollectionReference postsCollection;

  PostsRepository(){
    postsCollection = FirebaseFirestore.instance.collection('posts');
  }

  Future<void> addPost(Post post){
    var doc = postsCollection.doc();
    post.id = doc.id;
    return doc.set(post.toMap());
  }

  Future<void> updatePost(Post post){
    return postsCollection.doc(post.id).set(post.toMap());
  }

  Future<void> deletePost(Post post){
    return postsCollection.doc(post.id).delete();
  }

  Stream<List<Post>> loadAllPosts(){
     return postsCollection.snapshots().map((snapshot) {
       return convertToPosts(snapshot);
    },
    );
  }


  Stream<List<Post>> loadPostsOfUser(String uId){
    return postsCollection.where('uId', isEqualTo: uId).snapshots().map(
          (snapshot) {
            return convertToPosts(snapshot);
    },
    );
  }

  Future<List<Post>> loadAllPostsOnce() async {
    var snapshot = await postsCollection.get();
    return convertToPosts(snapshot);
  }

  List<Post> convertToPosts(QuerySnapshot snapshot){
    List<Post> posts = [];
    for(var snap in snapshot.docs){
      posts.add(Post.fromMap(snap.data() as Map<String, dynamic>));
    }
    return posts;
  }
}