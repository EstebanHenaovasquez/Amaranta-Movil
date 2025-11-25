import 'package:flutter/material.dart';
import 'package:amaranta/services/pedido_service.dart';
import 'package:amaranta/services/pending_order_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amaranta/widgets/main_navigation.dart';
import 'order_detail.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  bool loading = true;
  String? error;
  List<dynamic> apiOrders = [];
  List<Map<String, dynamic>> pending = [];

  static const Color amber = Color(0xFFD15113);
  static const Color darkGreen = Color(0xFF4A4B2F);
  static const Color bgBeige = Color(0xFFF5E6D3);

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _cancelOrder(int codigo) async {
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

    final res = await PedidoService.cancelarPedido(codigo);
    if (res['error'] != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'No se pudo cancelar: ${res['message'] ?? res['error']}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pedido cancelado correctamente')),
      );
      await _loadOrders();
    }
  }

  Future<void> _loadOrders() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userEmail = prefs.getString('user_email');
      final token = prefs.getString('auth_token');

      final res = await PedidoService.obtenerPedidos(authToken: token);
      if (res['error'] != null) {
        error = res['message'] ?? 'Error obteniendo pedidos';
      } else {
        final all = res['data'] ?? [];

        // Si tenemos el correo del usuario, filtramos localmente por 'correo'
        if (userEmail != null && userEmail.isNotEmpty) {
          apiOrders =
              (all as List).where((p) {
                try {
                  final mp = p as Map<String, dynamic>;
                  final correo =
                      (mp['correo'] ?? mp['email'] ?? '')
                          .toString()
                          .toLowerCase();
                  return correo == userEmail.toLowerCase();
                } catch (_) {
                  return false;
                }
              }).toList();
        } else {
          apiOrders = all;
        }
      }
    } catch (e) {
      error = e.toString();
    }

    try {
      pending = await PendingOrderService.getAllPending();
    } catch (_) {
      // ignore
    }

    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5E6D3),
      appBar: AppBar(
        title: const Text(
          'Mis Pedidos',
          style: TextStyle(
            color: Color(0xFF2C3E2D),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF2C3E2D)),
      ),
      body:
          loading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    if (error != null) ...[
                      Text('Error: $error'),
                      const SizedBox(height: 12),
                    ],

                    if (pending.isNotEmpty) ...[
                      Card(
                        color: bgBeige,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.schedule, color: Colors.black),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Pedidos pendientes',
                                      style: TextStyle(
                                        color: darkGreen,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${pending.length} pedidos guardados localmente',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () async {
                                  final sent =
                                      await PendingOrderService.retryAll();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Reintentados $sent pedidos',
                                      ),
                                    ),
                                  );
                                  await _loadOrders();
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: amber,
                                  foregroundColor: Colors.white,
                                ),
                                child: const Text('Reintentar'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],

                    Expanded(
                      child:
                          apiOrders.isEmpty
                              ? const Center(
                                child: Text('No hay pedidos en la API'),
                              )
                              : ListView.builder(
                                itemCount: apiOrders.length,
                                itemBuilder: (context, i) {
                                  final p =
                                      apiOrders[i] as Map<String, dynamic>;
                                  final id =
                                      p['codigoPedido'] ?? p['id'] ?? 'N/A';
                                  final fecha =
                                      p['fechaPedido'] ?? p['fecha'] ?? '';
                                  final total =
                                      p['precioTotal'] ?? p['precio'] ?? 0;
                                  final estado = p['estado'] ?? '';

                                  return Card(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 4,
                                    child: InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder:
                                                (_) => OrderDetailScreen(
                                                  orderData: p,
                                                ),
                                          ),
                                        );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(12.0),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.receipt_long,
                                              color: Colors.black,
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Pedido #$id',
                                                    style: TextStyle(
                                                      color: darkGreen,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    '$fecha — Estado: $estado',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  '\$${total.toString()}',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFFD15113),
                                                  ),
                                                ),
                                                const SizedBox(height: 6),
                                                if ((estado
                                                            .toString()
                                                            .toLowerCase() !=
                                                        'cancelado') &&
                                                    (estado
                                                            .toString()
                                                            .toLowerCase() !=
                                                        'entregado'))
                                                  TextButton(
                                                    onPressed: () {
                                                      final maybeId =
                                                          int.tryParse(
                                                            id.toString(),
                                                          );
                                                      if (maybeId != null)
                                                        _cancelOrder(maybeId);
                                                    },
                                                    style: TextButton.styleFrom(
                                                      foregroundColor: amber,
                                                    ),
                                                    child: const Text(
                                                      'Cancelar',
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),
      bottomNavigationBar: const MainNavigationBar(currentIndex: 2),
    );
  }
}
