// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../screens/register_screen.dart';
import '../screens/home_screen.dart';
import '../services/auth_service.dart';
import '../services/session_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _autoValidate = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final hasValidSession = await SessionManager.hasValidSession();
    if (hasValidSession && mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    }
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _autoValidate = true;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Guardar el contexto antes de las operaciones asíncronas
      final navigator = Navigator.of(context);

      await AuthService.login(
        _emailController.text,
        _passwordController.text,
      );

      final hasValidSession = await SessionManager.hasValidSession();
      if (!hasValidSession) {
        throw Exception('Error al iniciar sesión');
      }

      if (!mounted) return;

      _emailController.clear();
      _passwordController.clear();

      // Usar las referencias guardadas
      navigator.pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight,
                ),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                    child: Form(
                      key: _formKey,
                      autovalidateMode: _autoValidate
                          ? AutovalidateMode.onUserInteraction
                          : AutovalidateMode.disabled,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Align(
                            alignment: Alignment.center,
                            child: Image(
                              image: AssetImage('assets/logo.png'),
                              height: 120,
                              width: 120,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Center(
                            child: Text(
                              'BIENVENIDO A MSTORE',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          const Text('Email', style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              hintText: 'Ingresa el correo electrónico',
                            ),
                            keyboardType: TextInputType.emailAddress,
                            enabled: !_isLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu email';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Ingresa un email válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          const Text('Contraseña',
                              style: TextStyle(fontSize: 16)),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: !_isPasswordVisible,
                            enabled: !_isLoading,
                            decoration: InputDecoration(
                              hintText: 'Ingresa la contraseña',
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                  color: Colors.grey,
                                ),
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        setState(() {
                                          _isPasswordVisible =
                                              !_isPasswordVisible;
                                        });
                                      },
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              child: _isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                          Colors.white,
                                        ),
                                      ),
                                    )
                                  : const Text('Iniciar Sesión'),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "¿No tienes cuenta? ",
                                style: TextStyle(color: Colors.grey[400]),
                              ),
                              TextButton(
                                onPressed: _isLoading
                                    ? null
                                    : () async {
                                        _emailController.clear();
                                        _passwordController.clear();
                                        setState(() {
                                          _autoValidate = false;
                                        });
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const RegisterScreen(),
                                          ),
                                        );
                                      },
                                child: const Text('Regístrate'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
