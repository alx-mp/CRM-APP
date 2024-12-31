// lib/screens/account_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../widgets/bottom_navigation.dart';
import '../widgets/profile_image.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  String userName = '';
  String userEmail = '';
  bool _isLoading = true;
  bool _isImageLoading = false; // Nuevo estado para la carga de imagen
  String userId = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final profileData = await ProfileService.getUserProfile();
      //print('Profile Data: $profileData');

      if (!mounted) return;

      if (profileData != null) {
        setState(() {
          userId = profileData['id'];
          userName = profileData['first_name'];
          userEmail = profileData['email'];
          _isLoading = false;
        });
      } else {
        _redirectToLogin();
      }
    } catch (e) {
      //print('Error loading user data: $e');
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
                      'Perfil',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Stack(
                      children: [
                        ProfileImage(
                          radius: 50,
                          userId: userId,
                          onLoadingChanged: (isLoading) {
                            setState(() {
                              _isImageLoading =
                                  isLoading; // Usar el nuevo estado
                            });
                          },
                          onTap: () {}, // Enable image picking
                        ),
                        // Mostrar el indicador de carga solo si _isImageLoading es true
                        if (_isImageLoading)
                          const Positioned.fill(
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                      ],
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
                      title: const Text('Cerrar Sesión'),
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
