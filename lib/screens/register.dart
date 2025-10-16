import 'package:flutter/material.dart';
import '../services/registro_service.dart';
import 'verificacion.dart';

class AmarantaRegister extends StatefulWidget {
  final String? initialEmail;
  final String? initialName;
  final String? initialLastName;

  const AmarantaRegister({
    super.key,
    this.initialEmail,
    this.initialName,
    this.initialLastName,
  });

  @override
  State<AmarantaRegister> createState() => _AmarantaRegisterState();
}

class _AmarantaRegisterState extends State<AmarantaRegister> {
  final TextEditingController _documentController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _selectedDocumentType;

  final List<String> _documentTypes = [
    'Cédula de Ciudadanía',
    'Cédula de Extranjería',
  ];

  @override
  void dispose() {
    _documentController.dispose();
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null)
      _emailController.text = widget.initialEmail!;
    if (widget.initialName != null) _nameController.text = widget.initialName!;
    if (widget.initialLastName != null)
      _lastNameController.text = widget.initialLastName!;
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool? passwordVisible,
    VoidCallback? togglePasswordVisibility,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Color(0xFF2C3E2D),
          ),
        ),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
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
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white70),
            suffixIcon:
                togglePasswordVisibility != null
                    ? IconButton(
                      icon: Icon(
                        passwordVisible!
                            ? Icons.visibility
                            : Icons.visibility_off,
                        color: Colors.white70,
                      ),
                      onPressed: togglePasswordVisibility,
                    )
                    : null,
          ),
          style: const TextStyle(color: Colors.white),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDocumentTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de Documento',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          initialValue: _selectedDocumentType,
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
            hintText: 'Selecciona tipo de documento',
            hintStyle: const TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF4A4B2F),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          items:
              _documentTypes.map((String documentType) {
                return DropdownMenuItem<String>(
                  value: documentType,
                  child: Text(
                    documentType,
                    style: const TextStyle(color: Colors.white),
                  ),
                );
              }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedDocumentType = newValue;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Por favor selecciona un tipo de documento';
            }
            return null;
          },
        ),
      ],
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
                      // Título
                      const Text(
                        'REGÍSTRATE',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2C3E2D),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Tipo de Documento
                      _buildDocumentTypeDropdown(),
                      const SizedBox(height: 16),

                      // Documento
                      _buildInputField(
                        label: 'Documento:',
                        controller: _documentController,
                        hintText: 'Número de documento',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu número de documento';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Nombre
                      _buildInputField(
                        label: 'Nombre:',
                        controller: _nameController,
                        hintText: 'Tu nombre',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu nombre';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Apellido
                      _buildInputField(
                        label: 'Apellido:',
                        controller: _lastNameController,
                        hintText: 'Tu apellido',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu apellido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Email
                      _buildInputField(
                        label: 'Email:',
                        controller: _emailController,
                        hintText: 'ejemplo@correo.com',
                        keyboardType: TextInputType.emailAddress,
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
                      const SizedBox(height: 16),

                      // Celular
                      _buildInputField(
                        label: 'Celular:',
                        controller: _phoneController,
                        hintText: 'Número de celular',
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu número de celular';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Contraseña
                      _buildInputField(
                        label: 'CONTRASEÑA:',
                        controller: _passwordController,
                        hintText: '••••••••',
                        obscureText: !_isPasswordVisible,
                        passwordVisible: _isPasswordVisible,
                        togglePasswordVisibility: () {
                          setState(() {
                            _isPasswordVisible = !_isPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingresa tu contraseña';
                          } else if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirmar Contraseña
                      _buildInputField(
                        label: 'CONFIRMAR CONTRASEÑA:',
                        controller: _confirmPasswordController,
                        hintText: '••••••••',
                        obscureText: !_isConfirmPasswordVisible,
                        passwordVisible: _isConfirmPasswordVisible,
                        togglePasswordVisibility: () {
                          setState(() {
                            _isConfirmPasswordVisible =
                                !_isConfirmPasswordVisible;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor confirma tu contraseña';
                          } else if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Botón Ingresar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final Map<String, dynamic> usuarioData = {
                                'tipoDocumento': _selectedDocumentType,
                                'documento': _documentController.text.trim(),
                                'nombre': _nameController.text.trim(),
                                'apellido': _lastNameController.text.trim(),
                                'correo': _emailController.text.trim(),
                                'telefono': _phoneController.text.trim(),
                                'clave': _passwordController.text.trim(),
                                'departamento': '',
                                'municipio': '',
                                'direccion': '',
                              };

                              final messenger = ScaffoldMessenger.of(context);
                              messenger.showSnackBar(
                                const SnackBar(
                                  content: Text('Registrando usuario...'),
                                ),
                              );

                              final resultado =
                                  await RegistroService.registrarUsuario(
                                    usuarioData,
                                  );

                              if (!mounted) return;

                              if (resultado['exito'] == true &&
                                  resultado['correo'] != null) {
                                final correo = resultado['correo'] as String;

                                // Abrimos la pantalla de verificación y esperamos a que termine
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (context) =>
                                            VerificationScreen(correo: correo),
                                  ),
                                );

                                if (!mounted) return;
                                // Tras completar la verificación, volver al llamador con éxito
                                Navigator.pop(context, true);
                                return;
                              } else {
                                messenger.showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      resultado['mensaje'] ??
                                          'Error desconocido',
                                    ),
                                  ),
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
                            'Registrar',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Link para volver al login
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          '¿Ya tienes cuenta? Inicia sesión',
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
