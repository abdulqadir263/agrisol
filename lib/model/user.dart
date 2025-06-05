class AppUser {
  final String uid;
  final String email;
  final String username;
  final String? contact;
  final String? location;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    this.contact,
    this.location,
  });

  factory AppUser.fromMap(Map<String, dynamic> map) {
    return AppUser(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      username: map['username'] ?? '',
      contact: map['contact'],
      location: map['location'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'contact': contact,
      'location': location,
    };
  }
}