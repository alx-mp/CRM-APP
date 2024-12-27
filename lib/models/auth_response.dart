// lib/models/auth_response.dart
class User {
  final String id;
  final String firstName;
  final String email;
  final String cedula;
  final int roleId;
  final bool status;

  User({
    required this.id,
    required this.firstName,
    required this.email,
    required this.cedula,
    required this.roleId,
    required this.status,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      email: json['email'] ?? '',
      cedula: json['cedula'] ?? '',
      roleId: json['role_id'] ?? 0,
      status: json['status'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'first_name': firstName,
        'email': email,
        'cedula': cedula,
        'role_id': roleId,
        'status': status,
      };
}

class AuthResponse {
  final User user;
  final String token;

  AuthResponse({
    required this.user,
    required this.token,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: User.fromJson(json['user'] ?? {}),
      token: json['token'] ?? '',
    );
  }
}
