
class User {
  final String id;
  final String email;
  final String role;

  User({
    required this.id,
    required this.email,
    this.role = 'user',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'role': role,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      email: map['email'],
      role: map['role'] ?? 'user',
    );
  }
}