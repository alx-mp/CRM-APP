// lib/services/token_service.dart
import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_response.dart';

class TokenService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final userData = {
      'id': user.id,
      'first_name': user.firstName,
      'email': user.email,
      'cedula': user.cedula,
      'role_id': user.roleId,
      'status': user.status,
    };
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  static Future<User?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userStr = prefs.getString(_userKey);
    if (userStr != null) {
      try {
        final userData = jsonDecode(userStr);
        return User.fromJson(userData);
      } catch (e) {
        // print('Error al deserializar usuario: $e');
        return null;
      }
    }
    return null;
  }

  static Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }
}
