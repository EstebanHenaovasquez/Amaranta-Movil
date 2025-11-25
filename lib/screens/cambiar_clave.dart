import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:amaranta/config/constants.dart';
import 'dart:convert';

class CambiarPasswordScreen extends StatefulWidget {
  final String correo;

  const CambiarPasswordScreen({super.key, required this.correo});

  @override
  State<CambiarPasswordScreen> createState() => _CambiarPasswordScreenState();
}

class _CambiarPasswordScreenState extends State<CambiarPasswordScreen> {
  final _codigoController = TextEditingController();
  final _nuevaClaveController = TextEditingController();
  final _confirmarClaveController = TextEditingController();
  bool _procesando = false;

  Future<void> _actualizarClave() async {
    final codigo = _codigoController.text.trim();
    final nuevaClave = _nuevaClaveController.text.trim();
    final confirmar = _confirmarClaveController.text.trim();

    if (codigo.isEmpty || nuevaClave.isEmpty || confirmar.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos.')),
      );
      return;
    }

    if (nuevaClave != confirmar) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    setState(() => _procesando = true);

    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/usuarios/RestablecerClave'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': widget.correo,
        'codigo': codigo,
        'nuevaClave': nuevaClave,
      }),
    );

    setState(() => _procesando = false);

    if (!mounted) return;

    if (response.statusCode == 200) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Contraseña actualizada'),
          content: const Text(
              'Debes volver a iniciar sesión con tu nueva contraseña.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).popUntil((route) => route.isFirst);
                Navigator.of(context).pushReplacementNamed('/login');
              },
              child: const Text('Aceptar'),
            ),
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Código inválido o expirado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        title: const Text('Restablecer contraseña'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Restablecer contraseña',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2C3E2D),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text('Código enviado a: ${widget.correo}',
                        style: const TextStyle(color: Color(0xFF2C3E2D))),
                    const SizedBox(height: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Código de verificación',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C3E2D),
                          ),
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _codigoController,
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
                            hintText: 'Código',
                            hintStyle: const TextStyle(color: Colors.white70),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nueva contraseña',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C3E2D),
                          ),
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _nuevaClaveController,
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
                            hintText: 'Nueva contraseña',
                            hintStyle: const TextStyle(color: Colors.white70),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Confirmar contraseña',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF2C3E2D),
                          ),
                        ),
                        const SizedBox(height: 7),
                        TextField(
                          controller: _confirmarClaveController,
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
                            hintText: 'Confirmar contraseña',
                            hintStyle: const TextStyle(color: Colors.white70),
                          ),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _procesando ? null : _actualizarClave,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD15113),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 2,
                        ),
                        child: _procesando
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                'Actualizar contraseña',
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
    );
  }
}
