import 'package:flutter/material.dart';
import 'package:amaranta/services/pedido_service.dart';

class OrderDetailScreen extends StatefulWidget {
  final Map<String, dynamic> orderData;

  const OrderDetailScreen({super.key, required this.orderData});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  bool _isCancelling = false;

  static const Color amber = Color(0xFFD15113);
  static const Color darkGreen = Color(0xFF4A4B2F);
  static const Color bgBeige = Color(0xFFF5E6D3);

  Map<String, dynamic> get orderData => widget.orderData;

  Future<void> _cancelOrder() async {
    final codigoRaw = orderData['codigoPedido'] ?? orderData['id'];
    final codigo = int.tryParse(codigoRaw?.toString() ?? '');
    if (codigo == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('ID de pedido inválido')));
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar cancelación'),
            content: const Text('¿Deseas cancelar este pedido?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Sí'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isCancelling = true);
    final res = await PedidoService.cancelarPedido(codigo);
    setState(() => _isCancelling = false);

    if (res['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo cancelar: ${res['message'] ?? res['error']}',
          ),
        ),
      );
    } else {
      setState(() => orderData['estado'] = 'Cancelado');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido cancelado correctamente')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final id = orderData['codigoPedido'] ?? orderData['id'] ?? 'N/A';
    final fecha = orderData['fechaPedido'] ?? orderData['fecha'] ?? '';
    final total = orderData['precioTotal'] ?? orderData['precio'] ?? 0;
    final estado = orderData['estado'] ?? 'Desconocido';
    final direccion = orderData['direccion'] ?? '';
    final nombreCliente =
        orderData['nombreCliente'] ?? orderData['cliente'] ?? '';
    final correo = orderData['correo'] ?? '';
    final detalles = orderData['detalles'] ?? orderData['items'] ?? [];

    return Scaffold(
      backgroundColor: bgBeige,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        title: Text('Pedido #$id', style: TextStyle(color: darkGreen)),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fecha', style: TextStyle(color: darkGreen)),
                        const SizedBox(height: 4),
                        Text(
                          fecha,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Estado', style: TextStyle(color: darkGreen)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: amber.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            estado,
                            style: TextStyle(
                              color: amber,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text('Cliente', style: TextStyle(color: darkGreen)),
                const SizedBox(height: 4),
                Text('$nombreCliente — $correo'),
                const SizedBox(height: 8),
                Text('Dirección', style: TextStyle(color: darkGreen)),
                const SizedBox(height: 4),
                Text(direccion),
                const SizedBox(height: 12),
                Divider(color: darkGreen.withOpacity(0.2)),
                const SizedBox(height: 12),
                Text('Total', style: TextStyle(color: darkGreen)),
                const SizedBox(height: 4),
                Text(
                  '\$${total.toString()}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Detalles',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child:
                      detalles is List && detalles.isNotEmpty
                          ? ListView.separated(
                            separatorBuilder: (_, __) => const Divider(),
                            itemCount: detalles.length,
                            itemBuilder: (context, i) {
                              final d = detalles[i] as Map<String, dynamic>;
                              final nombre =
                                  d['nombreProducto'] ??
                                  d['nombre'] ??
                                  d['productName'] ??
                                  'Producto';
                              final cantidad = d['cantidad'] ?? d['qty'] ?? 1;
                              final precio =
                                  (d['precioUnitario'] ?? d['precio'] ?? 0)
                                      .toString();
                              final subtotal =
                                  d['subtotal'] ??
                                  (cantidad *
                                      (d['precioUnitario'] ??
                                          d['precio'] ??
                                          0));

                              return ListTile(
                                contentPadding: EdgeInsets.zero,
                                title: Text(
                                  nombre,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Cantidad: $cantidad  •  Unit: \$$precio',
                                ),
                                trailing: Text(
                                  '\$${subtotal.toString()}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFFD15113),
                                  ),
                                ),
                              );
                            },
                          )
                          : const Center(
                            child: Text('No hay detalles disponibles'),
                          ),
                ),

                const SizedBox(height: 12),
                // Cancel button area
                if ((estado.toString().toLowerCase() != 'cancelado') &&
                    (estado.toString().toLowerCase() != 'entregado'))
                  SizedBox(
                    width: double.infinity,
                    child:
                        _isCancelling
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                              onPressed: _cancelOrder,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: amber,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Cancelar pedido'),
                            ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
