import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amaranta/services/pedido_service.dart';

class PendingOrderService {
  static const _key = 'pending_orders';

  /// Añade un pedido (payload JSON) a la cola local
  static Future<void> enqueue(Map<String, dynamic> orderJson) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    list.add(jsonEncode(orderJson));
    await prefs.setStringList(_key, list);
  }

  /// Obtiene todos los pedidos pendientes (como Map)
  static Future<List<Map<String, dynamic>>> getAllPending() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    return list.map((s) => jsonDecode(s) as Map<String, dynamic>).toList();
  }

  /// Intenta reenviar todos los pedidos pendientes. Retorna cuántos fueron enviados.
  static Future<int> retryAll() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (list.isEmpty) return 0;

    final remaining = <String>[];
    int success = 0;

    for (final s in list) {
      try {
        final map = jsonDecode(s) as Map<String, dynamic>;
        final res = await PedidoService.crearPedidoDesdeJson(map);
        if (res['error'] == null) {
          success++;
        } else {
          // keep for later
          remaining.add(s);
        }
      } catch (_) {
        remaining.add(s);
      }
    }

    await prefs.setStringList(_key, remaining);
    return success;
  }

  /// Borra todos los pendientes (uso administrativo)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
