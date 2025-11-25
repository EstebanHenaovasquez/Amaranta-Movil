import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:amaranta/config/constants.dart';

class PedidoService {
  static const String _baseUrl = AppConfig.apiBaseUrl;

  /// ✅ Crea un pedido - USANDO EL ENDPOINT CORRECTO
  static Future<Map<String, dynamic>> crearPedidoDesdeJson(
    Map<String, dynamic> pedidoData,
  ) async {
    try {
      // Construir el payload EXACTO que espera la API
      final payload = {
        "fechaPedido": pedidoData['fechaPedido'],
        "idCliente": pedidoData['idCliente'],
        "departamento": pedidoData['departamento'],
        "municipio": pedidoData['municipio'],
        "direccion": pedidoData['direccion'],
        "correo": pedidoData['correo'],
        "detalles":
            pedidoData['detalles']
                .map(
                  (detalle) => {
                    "codigoProducto": detalle['codigoProducto'],
                    "cantidad": detalle['cantidad'],
                  },
                )
                .toList(),
      };

      print('[PedidoService] 🚀 Enviando pedido al endpoint correcto');
      print('[PedidoService] Payload: ${jsonEncode(payload)}');

      final endpoint = '$_baseUrl/Pedidos/crear-con-detalles';

      try {
        final response = await http
            .post(
              Uri.parse(endpoint),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
              body: jsonEncode(payload),
            )
            .timeout(const Duration(seconds: 15));

        print('[PedidoService] 📊 Respuesta de POST $endpoint:');
        print('   Status: ${response.statusCode}');
        print('   Body: ${response.body}');

        if (response.statusCode == 200) {
          final responseData = jsonDecode(response.body);
          print('[PedidoService] ✅ PEDIDO CREADO EXITOSAMENTE');
          return {
            'success': true,
            'codigoPedido': responseData['codigoPedido'],
            'precioTotal': responseData['precioTotal'],
            'mensaje': responseData['mensaje'] ?? 'Pedido creado con éxito',
          };
        } else if (response.statusCode == 400) {
          print('[PedidoService] ❌ 400 Bad Request');
          try {
            final errorData = jsonDecode(response.body);
            return {
              'error': 'Error de validación',
              'message':
                  errorData['detalle'] ??
                  errorData['error'] ??
                  'Datos inválidos',
              'details': errorData,
            };
          } catch (e) {
            return {
              'error': 'Error 400',
              'message': 'Solicitud incorrecta: ${response.body}',
            };
          }
        } else {
          return {
            'error': 'Error ${response.statusCode}',
            'message': 'Error del servidor: ${response.body}',
          };
        }
      } catch (e) {
        print('[PedidoService] ❌ Error de conexión: $e');
        return {
          'error': 'Error de conexión',
          'message': 'No se pudo conectar con el servidor: $e',
        };
      }
    } catch (e) {
      print('[PedidoService] 💥 Error general: $e');
      return {
        'error': 'Error interno',
        'message': 'Error procesando la solicitud: $e',
      };
    }
  }

  /// ✅ Método para obtener pedidos existentes
  /// Obtener pedidos. Si se proporciona [authToken], se añadirá como
  /// Authorization: Bearer <token>. La API puede devolver solo pedidos
  /// del usuario autenticado si está implementado en backend.
  static Future<Map<String, dynamic>> obtenerPedidos({
    String? authToken,
  }) async {
    try {
      final headers = {'Accept': 'application/json'};
      if (authToken != null && authToken.isNotEmpty) {
        headers['Authorization'] = 'Bearer $authToken';
      }

      final response = await http
          .get(Uri.parse('$_baseUrl/Pedidos'), headers: headers)
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'data': data,
          'message': 'Pedidos obtenidos correctamente',
        };
      } else {
        return {
          'error': 'Error ${response.statusCode}',
          'message': 'No se pudo obtener los pedidos',
        };
      }
    } catch (e) {
      return {'error': e.toString(), 'message': 'Error al obtener pedidos'};
    }
  }

  /// Helper que busca token en SharedPreferences y llama a obtenerPedidos
  static Future<Map<String, dynamic>> obtenerPedidosConTokenLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      return await obtenerPedidos(authToken: token);
    } catch (e) {
      return {'error': e.toString(), 'message': 'Error al obtener token'};
    }
  }

  /// ✅ Método para cancelar pedido
  static Future<Map<String, dynamic>> cancelarPedido(int codigoPedido) async {
    try {
      final response = await http
          .put(
            Uri.parse('$_baseUrl/Pedidos/$codigoPedido/cancelar'),
            headers: {'Accept': 'application/json'},
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['mensaje'] ?? 'Pedido cancelado',
        };
      } else {
        return {
          'error': 'Error ${response.statusCode}',
          'message': 'No se pudo cancelar el pedido',
        };
      }
    } catch (e) {
      return {'error': e.toString(), 'message': 'Error al cancelar pedido'};
    }
  }
}
