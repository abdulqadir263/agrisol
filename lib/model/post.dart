import 'comment.dart';

class Post {
  String id;
  String uId;
  String authorUsername;
  String title;
  String description;
  String? image;
  String? category;
  List<Comment>? comments;
  String? authorLikedCommentId; // <-- NEW FIELD

  Post(
      this.id,
      this.uId,
      this.authorUsername,
      this.title,
      this.description, {
        this.image,
        this.category,
        this.comments,
        this.authorLikedCommentId, // <-- NEW FIELD
      });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      map['id'] ?? '',
      map['uId'] ?? '',
      map['authorUsername'] ?? '',
      map['title'] ?? '',
      map['description'] ?? '',
      image: map['image'],
      category: map['category'],
      comments: map['comments'] != null
          ? List<Comment>.from(
          (map['comments'] as List)
              .map((c) => Comment.fromMap(Map<String, dynamic>.from(c))))
          : [],
      authorLikedCommentId: map['authorLikedCommentId'], // <-- NEW FIELD
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uId': uId,
      'authorUsername': authorUsername,
      'title': title,
      'description': description,
      'image': image,
      'category': category,
      'comments': comments?.map((c) => c.toMap()).toList() ?? [],
      'authorLikedCommentId': authorLikedCommentId, // <-- NEW FIELD
    };
  }
}