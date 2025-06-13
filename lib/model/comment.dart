class Comment {
  String id;
  String authorUid;
  String authorUsername;
  String content;
  List<String> likedBy;

  Comment({
    required this.id,
    required this.authorUid,
    required this.authorUsername,
    required this.content,
    List<String>? likedBy,
  }) : likedBy = likedBy ?? [];

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      authorUid: map['authorUid'] ?? '',
      authorUsername: map['authorUsername'] ?? '',
      content: map['content'] ?? '',
      likedBy: (map['likedBy'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorUid': authorUid,
      'authorUsername': authorUsername,
      'content': content,
      'likedBy': likedBy,
    };
  }
}