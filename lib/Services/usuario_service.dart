import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:amaranta/config/constants.dart';

class UsuarioService {
  static const String baseUrl = AppConfig.apiBaseUrl;

  /// ✅ Obtener CLIENTE por correo - VERSIÓN CORREGIDA
  static Future<Map<String, dynamic>?> obtenerClientePorCorreo(
    String correo,
  ) async {
    final url = Uri.parse('$baseUrl/clientes');

    try {
      print('[DEBUG] 🔍 Buscando cliente en URL: $url');
      final response = await http.get(url);

      print('[DEBUG] 📡 Respuesta completa:');
      print('Status: ${response.statusCode}');
      print('Headers: ${response.headers}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        print('[DEBUG] ✅ Data parseada: $data');

        // Buscar el cliente con el correo específico en la lista
        if (data is List) {
          for (final cliente in data) {
            if (cliente is Map) {
              final correoCliente = cliente['correo']?.toString().toLowerCase();
              if (correoCliente == correo.toLowerCase()) {
                print('[DEBUG] 🎯 Cliente encontrado: $cliente');
                print('[DEBUG] 🔎 Campos disponibles: ${cliente.keys}');

                // Buscar posibles campos de ID
                final idFields =
                    cliente.keys
                        .where(
                          (key) => key.toString().toLowerCase().contains('id'),
                        )
                        .toList();
                print('[DEBUG] 🔎 Campos que contienen "id": $idFields');

                // CONVERSIÓN SEGURA A Map<String, dynamic>
                return _convertToStringKeyMap(cliente);
              }
            }
          }
          print('[DEBUG] ❌ Cliente no encontrado con correo: $correo');
          return null;
        } else if (data is Map) {
          // Si la API devuelve un objeto único en lugar de lista
          final correoCliente = data['correo']?.toString().toLowerCase();
          if (correoCliente == correo.toLowerCase()) {
            // CONVERSIÓN SEGURA A Map<String, dynamic>
            return _convertToStringKeyMap(data);
          }
          return null;
        } else {
          print('[DEBUG] ❌ Formato de respuesta inesperado');
          return null;
        }
      } else {
        debugPrint(
          '[UsuarioService] obtenerClientePorCorreo: status=${response.statusCode} body=${response.body}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('[UsuarioService] Exception obtenerClientePorCorreo: $e');
      return null;
    }
  }

  /// ✅ Método auxiliar para convertir Map<dynamic, dynamic> a Map<String, dynamic>
  static Map<String, dynamic>? _convertToStringKeyMap(
    Map<dynamic, dynamic>? originalMap,
  ) {
    if (originalMap == null) return null;

    final Map<String, dynamic> result = {};
    originalMap.forEach((key, value) {
      result[key.toString()] = value;
    });
    return result;
  }

  /// ✅ Método alternativo: Buscar cliente específico por correo
  static Future<Map<String, dynamic>?> obtenerClientePorCorreoDirecto(
    String correo,
  ) async {
    final url = Uri.parse(
      '$baseUrl/clientes/ObtenerPorCorreo?correo=${Uri.encodeComponent(correo)}',
    );

    try {
      print('[DEBUG] 🔍 Buscando cliente directo en URL: $url');
      final response = await http.get(url);

      print('[DEBUG] 📡 Respuesta directa:');
      print('Status: ${response.statusCode}');
      print('Body: ${response.body}');

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        print('[DEBUG] ✅ Cliente encontrado directamente: $data');

        if (data is Map) {
          return _convertToStringKeyMap(data);
        }
        return null;
      } else {
        print(
          '[DEBUG] ❌ Cliente no encontrado directamente, status: ${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      debugPrint(
        '[UsuarioService] Exception obtenerClientePorCorreoDirecto: $e',
      );
      return null;
    }
  }

  /// ✅ DEBUG helper: devuelve detalle de la petición para clientes
  static Future<Map<String, dynamic>> obtenerClientePorCorreoDetalle(
    String correo,
  ) async {
    final url = Uri.parse('$baseUrl/clientes');
    try {
      final response = await http.get(url);
      return {
        'status': response.statusCode,
        'body': response.body,
        'endpoint': url.toString(),
      };
    } catch (e) {
      return {'status': null, 'error': e.toString()};
    }
  }

  // Mantenemos los métodos de usuario por si los necesitas para otras funcionalidades
  static Future<Map<String, dynamic>?> obtenerUsuarioPorCorreo(
    String correo,
  ) async {
    final url = Uri.parse(
      '$baseUrl/Usuarios/ObtenerPorCorreo?correo=${Uri.encodeComponent(correo)}',
    );

    try {
      print('[DEBUG] 🔍 Buscando USUARIO en URL: $url');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final dynamic data = jsonDecode(response.body);
        print('[DEBUG] ✅ Usuario encontrado: $data');

        if (data is Map) {
          return _convertToStringKeyMap(data);
        }
        return null;
      } else {
        debugPrint(
          '[UsuarioService] obtenerUsuarioPorCorreo: status=${response.statusCode}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('[UsuarioService] Exception obtenerUsuarioPorCorreo: $e');
      return null;
    }
  }

  /// Actualizar usuario usando PUT con form-data, permitiendo imagen
  static Future<bool> actualizarUsuario(
    String correo,
    Map<String, String> datos, {
    String? imagenPerfil,
  }) async {
    final uri = Uri.parse(
      '$baseUrl/Usuarios/ActualizarPorCorreo/${Uri.encodeComponent(correo)}',
    );
    final request = http.MultipartRequest('PUT', uri);

    datos.forEach((key, value) {
      if (value.isNotEmpty) {
        request.fields[key] = value;
      }
    });

    if (imagenPerfil != null && imagenPerfil.isNotEmpty) {
      request.files.add(
        await http.MultipartFile.fromPath('foto', imagenPerfil),
      );
    }

    try {
      final response = await request.send();
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      debugPrint('Error al actualizar usuario: $e');
      return false;
    }
  }
}
