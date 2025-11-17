// models/user_model.dart
class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final DateTime createdAt;
  final String theme; // 'light', 'dark', 'auto'
  final String language; // 'pt', 'en', 'es', 'fr'

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.createdAt,
    this.theme = 'auto',
    this.language = 'pt',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'theme': theme,
      'language': language,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'],
      createdAt: DateTime.parse(map['createdAt']),
      theme: map['theme'] ?? 'auto',
      language: map['language'] ?? 'pt',
    );
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? phone,
    String? theme,
    String? language,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      createdAt: createdAt,
      theme: theme ?? this.theme,
      language: language ?? this.language,
    );
  }
}