import 'comment.dart';

class Post {
  String id;
  String uId;
  String title;
  String description;
  String? image;
  String? category;
  List<Comment>? comments;

  Post(
      this.id,
      this.uId,
      this.title,
      this.description, {
        this.image,
        this.category,
        this.comments,
      });

  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      map['id'] ?? '',
      map['uId'] ?? '',
      map['title'] ?? '',
      map['description'] ?? '',
      image: map['image'],
      category: map['category'],
      comments: map['comments'] != null
          ? List<Comment>.from(
          (map['comments'] as List)
              .map((c) => Comment.fromMap(Map<String, dynamic>.from(c))))
          : [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uId': uId,
      'title': title,
      'description': description,
      'image': image,
      'category': category,
      'comments': comments?.map((c) => c.toMap()).toList() ?? [],
    };
  }
}