// lib/services/session_manager.dart
import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_response.dart';
import 'token_service.dart';

class SessionManager {
  static const String _tokenExpirationKey = 'token_expiration';

  // Verificar si hay una sesión válida
  static Future<bool> hasValidSession() async {
    try {
      final token = await TokenService.getToken();
      if (token == null || token.isEmpty) return false;

      final expirationStr = await _getTokenExpiration();
      if (expirationStr == null) return false;

      final expiration = DateTime.parse(expirationStr);
      return expiration.isAfter(DateTime.now());
    } catch (e) {
      // print('Error verificando sesión: $e');
      return false;
    }
  }

  // Guardar la sesión completa
  static Future<void> saveSession(AuthResponse response) async {
    final prefs = await SharedPreferences.getInstance();

    // Guardar token y usuario
    await TokenService.saveToken(response.token);
    await TokenService.saveUser(response.user);

    // Calcular y guardar expiración
    // El token JWT incluye exp en payload que está en segundos desde epoch
    final parts = response.token.split('.');
    if (parts.length > 1) {
      try {
        final payload = _decodeBase64(parts[1]);
        if (payload.containsKey('exp')) {
          final expiration =
              DateTime.fromMillisecondsSinceEpoch(payload['exp'] * 1000);
          await prefs.setString(
              _tokenExpirationKey, expiration.toIso8601String());
        }
      } catch (e) {
        // print('Error decodificando token: $e');
      }
    }
  }

  // Cerrar sesión
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      TokenService.clearToken(),
      TokenService.clearUser(),
      prefs.remove(_tokenExpirationKey),
    ]);
  }

  // Obtener la fecha de expiración del token
  static Future<String?> _getTokenExpiration() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenExpirationKey);
  }

  // Decodificar base64 del token
  static Map<String, dynamic> _decodeBase64(String str) {
    String output = str.replaceAll('-', '+').replaceAll('_', '/');
    switch (output.length % 4) {
      case 0:
        break;
      case 2:
        output += '==';
        break;
      case 3:
        output += '=';
        break;
      default:
        throw Exception('Base64 string illegal');
    }
    return Map<String, dynamic>.from(
      jsonDecode(
        utf8.decode(
          base64Url.decode(output),
        ),
      ),
    );
  }
}
