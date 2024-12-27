// lib/widgets/auth_wrapper.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../screens/login_screen.dart';
import '../screens/home_screen.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthService.checkAuth(),
      builder: (context, snapshot) {
        // Mientras verifica la autenticación
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        // Si está autenticado
        if (snapshot.hasData && snapshot.data == true) {
          return const HomeScreen();
        }

        // Si no está autenticado
        return const LoginScreen();
      },
    );
  }
}
