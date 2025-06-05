class Comment {
  String id;
  String authorUid;
  String authorUsername;
  String content;
  DateTime? timestamp;
  List<String> likedBy;

  Comment({
    required this.id,
    required this.authorUid,
    required this.authorUsername,
    required this.content,
    this.timestamp,
    List<String>? likedBy,
  }) : likedBy = likedBy ?? [];

  factory Comment.fromMap(Map<String, dynamic> map) {
    return Comment(
      id: map['id'] ?? '',
      authorUid: map['authorUid'] ?? '',
      authorUsername: map['authorUsername'] ?? '',
      content: map['content'] ?? '',
      timestamp: map['timestamp'] != null
          ? DateTime.tryParse(map['timestamp'].toString())
          : null,
      likedBy: (map['likedBy'] as List?)?.map((e) => e.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorUid': authorUid,
      'authorUsername': authorUsername,
      'content': content,
      'timestamp': timestamp?.toIso8601String(),
      'likedBy': likedBy,
    };
  }
}