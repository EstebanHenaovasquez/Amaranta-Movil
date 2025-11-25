import 'package:amaranta/screens/recuperar_clave.dart';
import 'package:amaranta/screens/verificacion.dart';
import 'package:flutter/material.dart';
import '../services/login_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'register.dart';

class AmarantaLogin extends StatefulWidget {
  const AmarantaLogin({super.key});

  @override
  State<AmarantaLogin> createState() => _AmarantaLoginState();
}

class _AmarantaLoginState extends State<AmarantaLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3), // Color beige del fondo
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Título Amaranta
                      const Text(
                        'Amaranta',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E2D),
                        ),
                      ),
                      const SizedBox(height: 35),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            child: Image.asset(
                              'assets/img/AmaraLogo.png',
                              width: 60,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 35),

                      // Campo Email
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2C3E2D),
                            ),
                          ),
                          const SizedBox(height: 7),
                          TextFormField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF4A4B2F),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              hintText: 'ejemplo@correo.com',
                              hintStyle: const TextStyle(color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu email';
                              } else if (!RegExp(
                                r'^[^@]+@[^@]+\.[^@]+',
                              ).hasMatch(value)) {
                                return 'Formato de email no válido';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Campo Contraseña
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Contraseña',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF2C3E2D),
                            ),
                          ),
                          const SizedBox(height: 7),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: true,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFF4A4B2F),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 12,
                              ),
                              hintText: '••••••••',
                              hintStyle: const TextStyle(color: Colors.white70),
                            ),
                            style: const TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu contraseña';
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // ¿Has olvidado tu contraseña?
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => RecuperarPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            '¿Has olvidado tu contraseña?',
                            style: TextStyle(color: Color(0xFF2C3E2D)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Botón Iniciar sesión
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final correo = _emailController.text.trim();
                              final clave = _passwordController.text;

                              final messenger = ScaffoldMessenger.of(context);
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Verificando credenciales...'),
                                ),
                              );

                              bool navigateToVerification = false;
                              String? mensajeError;
                              try {
                                final respuesta = await LoginService.login(
                                  correo,
                                  clave,
                                );

                                if (respuesta.exito &&
                                    respuesta.usuario != null) {
                                  // Guardar correo del usuario en SharedPreferences
                                  try {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    await prefs.setString('user_email', correo);
                                  } catch (_) {}

                                  navigateToVerification = true;
                                } else {
                                  mensajeError = respuesta.mensaje;
                                }
                              } catch (e) {
                                mensajeError =
                                    'Error de red o del servidor: $e';
                              }

                              if (!mounted) return;

                              if (navigateToVerification) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            VerificationScreen(correo: correo),
                                  ),
                                );
                              } else if (mensajeError != null) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text(mensajeError)),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD15113),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Iniciar sesión',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ¿Aún no tienes una cuenta?
                      const Text(
                        '¿Aún no tienes una cuenta?',
                        style: TextStyle(
                          color: Color(0xFF2C3E2D),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Botón Registrarse
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Acción de registro
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AmarantaRegister(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD15113),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Registrarse',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
