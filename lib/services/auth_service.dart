// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/env.dart';
import '../models/auth_response.dart';
import '../models/register_request.dart';
import 'session_manager.dart';

class AuthService {
  static Future<bool> register(RegisterRequest request) async {
    try {
      final response = await http.post(
        Uri.parse('${Env.apiUrl}/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }

      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Error en el registro');
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  static Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${Env.apiUrl}/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Error en el inicio de sesión');
      }

      final responseData = jsonDecode(response.body);
      final authResponse = AuthResponse(
        user: User.fromJson(responseData['user']),
        token: responseData['token'],
      );

      // Usar SessionManager para guardar la sesión
      await SessionManager.saveSession(authResponse);
      return authResponse;
    } catch (e) {
      print('Error durante el login: $e');
      rethrow;
    }
  }

  static Future<void> logout() async {
    await SessionManager.clearSession();
  }

  static Future<bool> checkAuth() async {
    return SessionManager.hasValidSession();
  }
}
