// models/user.dart
class User {
  int id;
  String username;
  String password;
  String role;
  DateTime createdAt;
  DateTime updatedAt;

  User({
    required this.id,
    required this.username,
    required this.password,
    required this.role,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        username: json['username'],
        password: json['password'],
        role: json['role'],
        createdAt: DateTime.parse(json['created_at']),
        updatedAt: DateTime.parse(json['updated_at']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'password': password,
        'role': role,
        'created_at': createdAt.toIso8601String(),
        'updated_at': updatedAt.toIso8601String(),
      };
}
