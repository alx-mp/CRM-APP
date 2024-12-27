class RegisterRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String cedula;
  final String phone;
  final String password;
  final int roleId;

  RegisterRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.cedula,
    required this.phone,
    required this.password,
    this.roleId = 2,
  });

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'cedula': cedula,
      'phone': phone,
      'password': password,
      'role_id': roleId,
    };
  }
}
