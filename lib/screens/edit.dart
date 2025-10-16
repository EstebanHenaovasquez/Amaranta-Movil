import 'package:amaranta/Services/ubicacion_service.dart';
import 'package:flutter/material.dart';
import '../services/usuario_service.dart';
import 'categoria.dart';
import 'login.dart';

class EditProfileScreen extends StatefulWidget {
  final String correo;
  const EditProfileScreen({super.key, required this.correo});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  String? _selectedDepartment;
  String? _selectedMunicipality;

  List<String> _departments = [];
  List<String> _municipalities = [];

  @override
  void initState() {
    super.initState();
    _loadDepartamentos();
    _loadUserData();
  }

  void _loadDepartamentos() async {
    _departments = await UbicacionLocalService.obtenerDepartamentos();
    setState(() {});
  }

  void _loadUserData() async {
    final data = await UsuarioService.obtenerUsuarioPorCorreo(widget.correo);
    if (data != null) {
      _nameController.text = data['nombre'] ?? '';
      _lastNameController.text = data['apellido'] ?? '';
      _emailController.text = data['correo'] ?? '';
      _phoneController.text = data['telefono'] ?? '';
      _addressController.text = data['direccion'] ?? '';
      _selectedDepartment = data['departamento'];
      _selectedMunicipality = data['municipio'];

      if (_selectedDepartment != null) {
        _municipalities =
            await UbicacionLocalService.obtenerMunicipios(_selectedDepartment!);
      }

      setState(() {});
    }
  }

  Widget _buildInput(
    String label,
    TextEditingController controller,
    String hintText, {
    bool obscure = false,
    bool? visible,
    VoidCallback? toggle,
    TextInputType type = TextInputType.text,
    String? Function(String?)? customValidator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF2C3E2D),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 7),
        TextFormField(
          controller: controller,
          keyboardType: type,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF4A4B2F),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white70),
            suffixIcon: toggle != null
                ? IconButton(
                    icon: Icon(
                        visible! ? Icons.visibility : Icons.visibility_off,
                        color: Colors.white70),
                    onPressed: toggle,
                  )
                : null,
          ),
          style: const TextStyle(color: Colors.white),
          validator: customValidator ??
              (value) => value == null || value.isEmpty
                  ? 'Este campo es requerido'
                  : null,
        ),
      ],
    );
  }

  Widget _buildDropdown(String label, String? value, List<String> items,
      String hintText, void Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF2C3E2D),
                fontSize: 14,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 7),
        DropdownButtonFormField<String>(
          initialValue: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF4A4B2F),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(5),
                borderSide: BorderSide.none),
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.white70),
          ),
          style: const TextStyle(color: Colors.white),
          dropdownColor: const Color(0xFF4A4B2F),
          icon: const Icon(Icons.arrow_drop_down, color: Colors.white70),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child:
                        Text(item, style: const TextStyle(color: Colors.white)),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: (value) =>
              value == null || value.isEmpty ? 'Selecciona una opción' : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5E6D3),
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Text('Editar información',
            style: TextStyle(
                color: Color(0xFF2C3E2D),
                fontSize: 18,
                fontWeight: FontWeight.w600)),
        centerTitle: true,
      ),
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
                    children: [
                      _buildInput('Nombre', _nameController, 'Tu nombre'),
                      const SizedBox(height: 16),
                      _buildInput(
                          'Apellido', _lastNameController, 'Tu apellido'),
                      const SizedBox(height: 16),
                      _buildInput(
                          'Email', _emailController, 'ejemplo@correo.com',
                          type: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildInput(
                          'Teléfono', _phoneController, 'Número de celular',
                          type: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildDropdown('Departamento', _selectedDepartment,
                          _departments, 'Selecciona departamento', (val) async {
                        _selectedDepartment = val;
                        _selectedMunicipality = null;
                        _municipalities =
                            await UbicacionLocalService.obtenerMunicipios(val!);
                        setState(() {});
                      }),
                      const SizedBox(height: 16),
                      _buildDropdown('Municipio', _selectedMunicipality,
                          _municipalities, 'Selecciona municipio', (val) {
                        setState(() => _selectedMunicipality = val);
                      }),
                      const SizedBox(height: 16),
                      _buildInput(
                          'Dirección', _addressController, 'Tu dirección'),
                      const SizedBox(height: 16),
                      _buildInput(
                        'Contraseña',
                        _passwordController,
                        'Nueva contraseña (opcional)',
                        obscure: !_isPasswordVisible,
                        visible: _isPasswordVisible,
                        toggle: () => setState(
                            () => _isPasswordVisible = !_isPasswordVisible),
                        customValidator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              final datos = {
                                'nombre': _nameController.text.trim(),
                                'apellido': _lastNameController.text.trim(),
                                'correo': _emailController.text.trim(),
                                'telefono': _phoneController.text.trim(),
                                'direccion': _addressController.text.trim(),
                                'departamento': _selectedDepartment ?? '',
                                'municipio': _selectedMunicipality ?? '',
                              };
                              if (_passwordController.text.trim().isNotEmpty) {
                                datos['clave'] =
                                    _passwordController.text.trim();
                              }

                              final messenger = ScaffoldMessenger.of(context);

                              final ok = await UsuarioService.actualizarUsuario(
                                  widget.correo, datos);

                              if (!mounted) return;

                              if (ok) {
                                messenger.showSnackBar(const SnackBar(
                                    content: Text(
                                        'Información actualizada exitosamente')));
                              } else {
                                messenger.showSnackBar(const SnackBar(
                                    content: Text(
                                        'Error al actualizar la información')));
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD15113),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text('Editar',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => CategoriasScreen()),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(
                                0xFFD15113), // Naranja igual que el de editar
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text('Ir a Categorías',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Cerrar sesión'),
                                content: const Text(
                                    '¿Estás seguro de que deseas cerrar sesión?'),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(false),
                                    child: const Text('Cancelar'),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(true),
                                    child: const Text('Cerrar sesión',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                            if (confirm == true) {
                              final messenger = ScaffoldMessenger.of(context);
                              final navigator = Navigator.of(context);
                              messenger.showSnackBar(
                                const SnackBar(
                                    content:
                                        Text('Sesión cerrada correctamente')),
                              );
                              await Future.delayed(
                                  const Duration(milliseconds: 500));
                              if (!mounted) return;
                              navigator.pushAndRemoveUntil(
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const AmarantaLogin()),
                                (route) => false,
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25)),
                          ),
                          child: const Text('Cerrar sesión',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600)),
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
