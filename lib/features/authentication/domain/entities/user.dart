class User {
  const User({
    required this.id,
    required this.name,
    required this.email,
    required this.username,
  });

  final String id;
  final String name;
  final String email;
  final String username;

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      username: json['username']?.toString() ?? '',
    );
  }
}
