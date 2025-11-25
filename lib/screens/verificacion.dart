import 'package:amaranta/services/verificacion_service.dart';
import 'edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerificationScreen extends StatefulWidget {
  final String correo;

  const VerificationScreen({super.key, required this.correo});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String get verificationCode =>
      _controllers.map((controller) => controller.text).join();
  bool get isCodeComplete => verificationCode.length == 6;

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onCodeChanged(String value, int index) {
    if (value.length == 1 && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    setState(() {});
  }

  void _onKeyDown(RawKeyEvent event, int index) {
    if (event is RawKeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace) {
      if (_controllers[index].text.isEmpty && index > 0) {
        _focusNodes[index - 1].requestFocus();
      }
    }
  }

  void _validateCode() async {
    if (!isCodeComplete) return;

    debugPrint('Verificando con código: $verificationCode');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Verificando código...')),
    );

    final validado = await VerificacionService.validarCodigo(
        widget.correo, verificationCode);

    if (!mounted) return;

    if (validado) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Código verificado correctamente'),
            backgroundColor: Colors.green),
      );

      // Aquí podrías navegar a la pantalla de editar
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfileScreen(correo: widget.correo),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Código incorrecto. Inténtalo de nuevo.'),
            backgroundColor: Colors.red),
      );
      _clearCode();
    }
  }

  void _clearCode() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
    setState(() {});
  }

  void _resendCode() async {
    final reenviado = await VerificacionService.reenviarCodigo(widget.correo);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(reenviado
            ? 'Código reenviado a tu correo'
            : 'No se pudo reenviar el código'),
        backgroundColor: const Color(0xFF4A4B2F),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Container(
                padding: const EdgeInsets.all(32.0),
                width: double.infinity,
                constraints: const BoxConstraints(maxWidth: 400),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Amaranta',
                        style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2C3E2D)),
                      ),
                      const SizedBox(height: 35),
                      Image.asset(
                        'assets/img/AmaraLogo.png',
                        width: 60,
                        height: 80,
                      ),
                      const SizedBox(height: 35),
                      const Text(
                        'Ingrese el código enviado\na su email.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF2C3E2D),
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 40),
                      // RawKeyboardListener is deprecated; migrate to KeyboardListener in a follow-up
                      // ignore: deprecated_member_use
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(6, (index) {
                          return SizedBox(
                            width: 40,
                            height: 50,
                            child: RawKeyboardListener(
                              focusNode: FocusNode(),
                              onKey: (event) => _onKeyDown(event, index),
                              child: TextFormField(
                                controller: _controllers[index],
                                focusNode: _focusNodes[index],
                                textAlign: TextAlign.center,
                                keyboardType: TextInputType.number,
                                maxLength: 1,
                                inputFormatters: [
                                  FilteringTextInputFormatter.digitsOnly
                                ],
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                                decoration: InputDecoration(
                                  counterText: '',
                                  filled: true,
                                  fillColor: const Color(0xFF4A4B2F),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide.none,
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2C3E2D),
                                      width: 2,
                                    ),
                                  ),
                                ),
                                onChanged: (value) =>
                                    _onCodeChanged(value, index),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isCodeComplete ? _validateCode : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD15113),
                            foregroundColor: Colors.white,
                            disabledBackgroundColor:
                                const Color.fromRGBO(209, 81, 19, 0.5),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Validar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        '¿No recibiste el código?',
                        style: TextStyle(
                          color: Color(0xFF2C3E2D),
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _resendCode,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A4B2F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 2,
                          ),
                          child: const Text(
                            'Reenviar código',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Volver al inicio de sesión',
                          style: TextStyle(
                            color: Color(0xFF2C3E2D),
                            fontSize: 14,
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
