import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amaranta/config/constants.dart';
import 'package:flutter/foundation.dart';

class VerificacionService {
  static const String baseUrl = '${AppConfig.apiBaseUrl}/Usuarios';

  static Future<bool> validarCodigo(String correo, String codigo) async {
    final url = Uri.parse('$baseUrl/VerificarCodigo');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'codigo': codigo}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      debugPrint(
          'Código incorrecto: ${response.statusCode} - ${response.body}'); // Agrega esto temporalmente
      return false;
    }
  }

  static Future<bool> reenviarCodigo(String correo) async {
    final url = Uri.parse('$baseUrl/EnviarCodigoRegistro');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo}),
    );

    return response.statusCode == 200;
  }

  static Future<bool> restablecerClave(
      String correo, String codigo, String nuevaClave) async {
    final response = await http.post(
      Uri.parse('${AppConfig.apiBaseUrl}/usuarios/RestablecerClave'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'correo': correo,
        'codigo': codigo,
        'nuevaClave': nuevaClave,
      }),
    );
    return response.statusCode == 200;
  }
}
