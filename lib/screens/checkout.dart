import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amaranta/services/ubicacion_service.dart';
import 'package:amaranta/models/cart.dart';
import 'package:amaranta/services/pedido_service.dart';
import 'package:amaranta/services/usuario_service.dart';
import 'package:amaranta/screens/register.dart';
import 'package:amaranta/services/pending_order_service.dart';
import 'package:amaranta/screens/categoria.dart';
import 'package:amaranta/screens/orders.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _correoCtl = TextEditingController();
  final _direccionCtl = TextEditingController();

  bool _cancelRetries = false;
  bool _loading = false;

  String? _departamento;
  String? _municipio;
  List<String> _departamentos = [];
  List<String> _municipios = [];

  @override
  void initState() {
    super.initState();
    _loadDepartamentos();
    _loadUserData();
  }

  void _loadUserData() {
    // Aquí puedes cargar datos del usuario logueado si tu app los tiene guardados.
  }

  Future<void> _loadDepartamentos() async {
    try {
      final d = await UbicacionLocalService.obtenerDepartamentos();
      setState(() => _departamentos = d);
    } catch (e) {
      print('Error loading departments: $e');
    }
  }

  Future<void> _onDepartamentoChanged(String? value) async {
    if (value == null) return;
    setState(() {
      _departamento = value;
      _municipio = null;
      _municipios = [];
    });
    try {
      final m = await UbicacionLocalService.obtenerMunicipios(value);
      setState(() => _municipios = m);
    } catch (e) {
      print('Error loading municipalities: $e');
    }
  }

  Map<String, dynamic> _getProductData(dynamic cartItem) {
    try {
      final producto = (cartItem is CartItem) ? cartItem.product : cartItem;
      final cantidad =
          (cartItem is CartItem)
              ? cartItem.quantity
              : (cartItem['cantidad'] ?? 1);

      final codigo =
          producto.codigoProducto ??
          producto['codigoProducto'] ??
          producto['id'] ??
          0;
      final nombre =
          producto.nombreProducto ??
          producto['nombreProducto'] ??
          producto['nombre'] ??
          'Producto';

      double precio = 0.0;
      if (producto.precio != null) {
        precio = (producto.precio as num).toDouble();
      } else if (producto['precio'] != null) {
        precio = double.tryParse(producto['precio'].toString()) ?? 0.0;
      }

      return {
        'codigoProducto': codigo,
        'nombreProducto': nombre,
        'cantidad': cantidad,
        'precioUnitario': precio,
      };
    } catch (e) {
      print('Error en _getProductData: $e');
      return {
        'codigoProducto': 0,
        'nombreProducto': 'Producto no disponible',
        'cantidad': 1,
        'precioUnitario': 0.0,
      };
    }
  }

  /// ✅ ENVÍA EL PEDIDO - VERSIÓN ACTUALIZADA CON idCliente
  Future<void> _submitOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = Provider.of<CartModel>(context, listen: false);
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El carrito está vacío')));
      return;
    }

    setState(() => _loading = true);

    final correo = _correoCtl.text.trim();
    Map<String, dynamic>? cliente;
    int idCliente = 0; // CAMBIO: idCliente en lugar de idUsuario
    String nombreCliente = correo;

    try {
      print('[DEBUG] Buscando cliente con correo: $correo');

      // 1. Buscar cliente por correo
      cliente = await UsuarioService.obtenerClientePorCorreo(correo);
      print('[DEBUG] Respuesta de obtenerClientePorCorreo: $cliente');

      if (cliente != null) {
        // OBTENER idCliente CORRECTAMENTE
        idCliente = cliente['idCliente'] ?? cliente['id'] ?? 0;

        final nombre = cliente['nombre'] ?? '';
        final apellido = cliente['apellido'] ?? '';
        nombreCliente = (nombre + ' ' + apellido).trim();
        if (nombreCliente.isEmpty) nombreCliente = correo;

        print(
          '[DEBUG] Cliente encontrado - ID: $idCliente, Nombre: $nombreCliente',
        );

        // SOLUCIÓN TEMPORAL: Si no tenemos ID
        if (idCliente == 0 && cliente.isNotEmpty) {
          print(
            '[DEBUG] ⚠️ Cliente encontrado pero sin ID. Aplicando solución temporal...',
          );
          idCliente = _obtenerIdClientePorCorreo(correo);
          print('[DEBUG] 🔧 ID asignado temporalmente: $idCliente');
        }
      } else {
        print('[DEBUG] Cliente NO encontrado en la API');
      }
    } catch (e) {
      print('[DEBUG] Error obteniendo cliente: $e');
    }

    // 2. Si encontramos cliente pero sin ID, preguntar al usuario
    if (cliente != null && idCliente == 0) {
      setState(() => _loading = false);

      final action = await showDialog<String>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Información del cliente incompleta'),
              content: Text(
                'Encontramos a $nombreCliente pero no pudimos obtener su ID completo.\n\n'
                'Correo: $correo\n'
                '¿Deseas continuar con el pedido?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop('cancel'),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('continue'),
                  child: const Text('Continuar'),
                ),
              ],
            ),
      );

      if (action == 'continue') {
        setState(() => _loading = true);
        idCliente = _obtenerIdClientePorCorreo(correo);
        await _processOrder(correo, idCliente, nombreCliente, cart);
      }
      return;
    }
    // 3. Si no encontramos cliente, mostrar opción de registro
    else if (cliente == null) {
      setState(() => _loading = false);

      final action = await showDialog<String>(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('Cliente no encontrado'),
              content: const Text(
                'No encontramos un cliente con ese correo. ¿Deseas registrarte?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop('cancel'),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop('register'),
                  child: const Text('Registrarme'),
                ),
              ],
            ),
      );

      if (action == 'register') {
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder:
                (_) => AmarantaRegister(
                  initialEmail: correo,
                  initialName: nombreCliente.split(' ').first,
                  initialLastName: nombreCliente.split(' ').skip(1).join(' '),
                ),
          ),
        );
      }
      return;
    } else {
      // 4. Si tenemos cliente con ID, procesar normalmente
      await _processOrder(correo, idCliente, nombreCliente, cart);
    }
  }

  /// ✅ SOLUCIÓN TEMPORAL: Mapeo de correos a idCliente
  int _obtenerIdClientePorCorreo(String correo) {
    // Agrega aquí los correos e IDs que conozcas - USANDO idCliente
    final mapaCorreosIds = {
      'juanes@gmail.com': 14, // ID del cliente Juan Henao
      'mirandaleider4@gmail.com': 15,
      'ejemplo@correo.com': 1,
    };

    return mapaCorreosIds[correo] ?? 0;
  }

  /// ✅ PROCESAR PEDIDO CON idCliente
  Future<void> _processOrder(
    String correo,
    int idCliente, // CAMBIO: idCliente en lugar de idUsuario
    String nombreCliente,
    CartModel cart,
  ) async {
    // Construir detalles del pedido
    final detalles = <Map<String, dynamic>>[];
    double total = 0;

    for (final cartItem in cart.items) {
      final productData = _getProductData(cartItem);
      final cantidad = productData['cantidad'] as int;
      final precioUnitario = productData['precioUnitario'] as double;
      final subtotal = cantidad * precioUnitario;
      total += subtotal;

      detalles.add({
        "codigoProducto": productData['codigoProducto'],
        "nombreProducto": productData['nombreProducto'],
        "cantidad": cantidad,
        "precioUnitario": precioUnitario,
        "subtotal": subtotal,
      });
    }

    // Validar que tenemos datos válidos
    if (detalles.isEmpty || total <= 0) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: productos sin precios válidos')),
      );
      return;
    }

    // Crear payload con estructura CORRECTA usando idCliente
    final payload = {
      "codigoPedido": 0,
      "fechaPedido": DateTime.now().toIso8601String().split('T').first,
      "precioTotal": total,
      "estado": "Pendiente",
      "direccion": _direccionCtl.text.trim(),
      "municipio": _municipio ?? '',
      "departamento": _departamento ?? '',
      "correo": correo,
      "idCliente": idCliente, // CAMBIO IMPORTANTE: idCliente
      "nombreCliente": nombreCliente,
      "detalles": detalles,
    };

    print('[Checkout] Payload final con idCliente: $payload');

    // Enviar pedido
    await _sendOrderWithRetry(payload, cart);
  }

  Future<void> _sendOrderWithRetry(
    Map<String, dynamic> payload,
    CartModel cart,
  ) async {
    Map<String, dynamic>? result;
    const int maxAttempts = 3;

    _cancelRetries = false;
    final messenger = ScaffoldMessenger.of(context);

    messenger.showSnackBar(
      SnackBar(
        content: const Text('Intentando enviar pedido...'),
        duration: const Duration(seconds: 30),
        action: SnackBarAction(
          label: 'Cancelar',
          onPressed: () {
            setState(() => _cancelRetries = true);
            messenger.hideCurrentSnackBar();
          },
        ),
      ),
    );

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      if (_cancelRetries) break;

      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Reintentando envío... intento $attempt de $maxAttempts',
          ),
          duration: const Duration(seconds: 30),
          action: SnackBarAction(
            label: 'Cancelar',
            onPressed: () {
              setState(() => _cancelRetries = true);
              messenger.hideCurrentSnackBar();
            },
          ),
        ),
      );

      try {
        result = await PedidoService.crearPedidoDesdeJson(payload);
        if (!_cancelRetries && result['error'] == null) break;
        if (result['status'] == 405) break;
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      } catch (e) {
        print('Error en intento $attempt: $e');
        result = {'error': e.toString()};
        if (attempt < maxAttempts) {
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }

    messenger.hideCurrentSnackBar();
    setState(() => _loading = false);
    await _handleOrderResult(result, payload, cart);
  }

  Future<void> _handleOrderResult(
    Map<String, dynamic>? result,
    Map<String, dynamic> payload,
    CartModel cart,
  ) async {
    if (result != null && result['error'] == null) {
      cart.clear();
      final codigo = result['codigoPedido'] ?? result['id'] ?? 'N/A';
      await showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text('✅ Pedido enviado'),
              content: Text('Pedido creado exitosamente. ID: $codigo'),
              actions: [
                TextButton(
                  onPressed: () {
                    // Cerrar diálogo y regresar a la pantalla de categorías (seguir comprando)
                    Navigator.of(context).pop();
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (_) => const CategoriasScreen(),
                      ),
                      (route) => false,
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD15113),
                  ),
                  child: const Text('Seguir comprando'),
                ),
                TextButton(
                  onPressed: () {
                    // Cerrar diálogo y navegar a la pantalla de pedidos
                    Navigator.of(context).pop();
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const OrdersScreen()),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFD15113),
                  ),
                  child: const Text('Ver mis pedidos'),
                ),
              ],
            ),
      );
      return;
    }

    final errorMsg = result?['error'] ?? 'Error desconocido';

    final choice = await showDialog<String>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('No fue posible enviar el pedido'),
            content: Text('Error: $errorMsg'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop('cancel'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD15113),
                ),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop('queue'),
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFFD15113),
                ),
                child: const Text('Guardar en cola'),
              ),
            ],
          ),
    );

    if (choice == 'queue') {
      await PendingOrderService.enqueue(payload);
      cart.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pedido guardado en cola para reintentar luego'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Confirmar Dirección',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFFD15113),
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con icono
            _buildHeader(),
            const SizedBox(height: 24),

            // Formulario
            _buildForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD15113), Color(0xFFF57C00)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.location_on_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dirección de Entrega',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Confirma dónde quieres recibir tu pedido',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Campo de correo
            _buildTextField(
              controller: _correoCtl,
              label: 'Correo Electrónico',
              hintText: 'ejemplo@correo.com',
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
              validator:
                  (v) =>
                      v == null || !v.contains('@')
                          ? 'Ingrese un correo válido'
                          : null,
            ),
            const SizedBox(height: 20),

            // Campo de departamento
            _buildDropdown(
              value: _departamento,
              items: _departamentos,
              label: 'Departamento',
              icon: Icons.map_rounded,
              onChanged: _onDepartamentoChanged,
              validator:
                  (v) =>
                      v == null || v.isEmpty ? 'Seleccione departamento' : null,
            ),
            const SizedBox(height: 20),

            // Campo de municipio
            _buildDropdown(
              value: _municipio,
              items: _municipios,
              label: 'Municipio',
              icon: Icons.location_city_rounded,
              onChanged: (v) => setState(() => _municipio = v),
              validator:
                  (v) => v == null || v.isEmpty ? 'Seleccione municipio' : null,
            ),
            const SizedBox(height: 20),

            // Campo de dirección
            _buildTextField(
              controller: _direccionCtl,
              label: 'Dirección Completa',
              hintText: 'Calle, número, barrio, referencia...',
              icon: Icons.home_rounded,
              maxLines: 3,
              validator:
                  (v) => v == null || v.isEmpty ? 'Ingrese dirección' : null,
            ),
            const SizedBox(height: 32),

            // Botón de confirmar
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          style: const TextStyle(fontSize: 16),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500]),
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              child: Icon(icon, color: const Color(0xFFD15113), size: 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD15113), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required List<String> items,
    required String label,
    required IconData icon,
    required void Function(String?)? onChanged,
    required String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items:
              items
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: const TextStyle(fontSize: 16)),
                    ),
                  )
                  .toList(),
          onChanged: onChanged,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Container(
              margin: const EdgeInsets.all(12),
              child: Icon(icon, color: const Color(0xFFD15113), size: 20),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFD15113), width: 2),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          ),
          icon: const Icon(
            Icons.arrow_drop_down_rounded,
            color: Color(0xFFD15113),
          ),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: const TextStyle(color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    if (_loading) {
      return Container(
        width: double.infinity,
        height: 56,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD15113), Color(0xFFF57C00)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Procesando pedido...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _submitOrder,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD15113),
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: Colors.orange.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_rounded, size: 20),
            const SizedBox(width: 8),
            const Text(
              'Confirmar y Enviar Pedido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _correoCtl.dispose();
    _direccionCtl.dispose();
    super.dispose();
  }
}
