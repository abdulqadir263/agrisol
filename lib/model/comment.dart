class Comment {
  String id;
  String authorEmail;
  String content;

  Comment({
    required this.id,
    required this.authorEmail,
    required this.content,
  });

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      authorEmail: map['authorEmail'] ?? '',
      content: map['content'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorEmail': authorEmail,
      'content': content,
    };
  }
}