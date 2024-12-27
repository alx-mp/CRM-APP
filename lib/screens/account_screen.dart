// lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/token_service.dart';
import '../widgets/bottom_navigation.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String userName = '';
  String userEmail = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = await TokenService.getUser();
      if (!mounted) return;

      if (user != null) {
        setState(() {
          userName = user.firstName;
          userEmail = user.email;
          _isLoading = false;
        });
      } else {
        _redirectToLogin();
      }
    } catch (e) {
      _redirectToLogin();
    }
  }

  void _redirectToLogin() {
    if (!mounted) return;
    Navigator.of(context).pushReplacementNamed('/login');
  }

  Future<void> _handleLogout() async {
    try {
      await AuthService.logout();
      if (!mounted) return;
      _redirectToLogin();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error al cerrar sesión'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Profile',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    const CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Hola, $userName',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userEmail,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),
                    ListTile(
                      leading: const Icon(Icons.logout),
                      title: const Text('Logout'),
                      onTap: _handleLogout,
                    ),
                    const Spacer(),
                    const SizedBox(height: 16),
                    const BottomNavigation(currentIndex: 3),
                  ],
                ),
              ),
            ),
    );
  }
}
