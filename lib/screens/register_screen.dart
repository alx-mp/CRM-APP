// lib/screens/register_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/ecuador_id_validator.dart';
import '../services/auth_service.dart';
import '../models/register_request.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  // Controllers
  final _cedulaController = TextEditingController();
  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  Future<void> _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final request = RegisterRequest(
          firstName: _nameController.text,
          lastName: _lastNameController.text,
          email: _emailController.text,
          cedula: _cedulaController.text,
          phone: _phoneController.text,
          password: _passwordController.text,
        );

        final success = await AuthService.register(request);

        if (!mounted) return;

        if (success) {
          // Mostrar mensaje de éxito
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Registro exitoso. Por favor, inicia sesión.'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );

          // Volver a la pantalla de login
          Navigator.of(context).pop();
        }
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Center(
                          child: Text(
                            'Registro de Usuario',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: Image.asset(
                            'assets/logo.png',
                            height: 100,
                            width: 100,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text('Cédula', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        _NumericFormField(
                          controller: _cedulaController,
                          hintText: 'Ingresa tu cédula',
                          maxLength: 10,
                          validateId: true,
                        ),
                        const SizedBox(height: 16),
                        const Text('Nombre', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _nameController,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            hintText: 'Ingresa tu nombre',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu nombre';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Apellido', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _lastNameController,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            hintText: 'Ingresa tu apellido',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu apellido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Teléfono', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        _NumericFormField(
                          controller: _phoneController,
                          hintText: 'Ingresa tu número de teléfono',
                          maxLength: 10,
                        ),
                        const SizedBox(height: 16),
                        const Text('Email', style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _emailController,
                          enabled: !_isLoading,
                          decoration: const InputDecoration(
                            hintText: 'Ingresa tu correo electrónico',
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu email';
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
                          enabled: !_isLoading,
                          obscureText: !_isPasswordVisible,
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
                              return 'Ingresa tu contraseña';
                            }
                            if (value.length < 6) {
                              return 'La contraseña debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Confirmar Contraseña',
                            style: TextStyle(fontSize: 16)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _confirmPasswordController,
                          enabled: !_isLoading,
                          obscureText: !_isConfirmPasswordVisible,
                          decoration: InputDecoration(
                            hintText: 'Confirma tu contraseña',
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isConfirmPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                                color: Colors.grey,
                              ),
                              onPressed: _isLoading
                                  ? null
                                  : () {
                                      setState(() {
                                        _isConfirmPasswordVisible =
                                            !_isConfirmPasswordVisible;
                                      });
                                    },
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Confirma tu contraseña';
                            }
                            if (value != _passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleRegister,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text('Registrarse'),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "¿Ya tienes una cuenta? ",
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              Navigator.pop(context);
                            },
                      child: const Text('Iniciar Sesión'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _cedulaController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}

class _NumericFormField extends StatelessWidget {
  final String hintText;
  final int maxLength;
  final bool validateId;
  final TextEditingController? controller;

  const _NumericFormField({
    required this.hintText,
    required this.maxLength,
    this.validateId = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        counterText: '',
      ),
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(maxLength),
      ],
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es requerido';
        }
        if (validateId) {
          return EcuadorIdValidator.validate(value);
        }
        if (value.length != maxLength) {
          return 'Debe tener $maxLength dígitos';
        }
        return null;
      },
      autovalidateMode: validateId
          ? AutovalidateMode.onUserInteraction
          : AutovalidateMode.disabled,
    );
  }
}
