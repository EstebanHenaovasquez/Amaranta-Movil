import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amaranta/config/constants.dart';

class RegistroService {
  static const String baseUrl = '${AppConfig.apiBaseUrl}/Usuarios';

  static Future<Map<String, dynamic>> registrarUsuario(Map<String, dynamic> usuarioData) async {
    final uri = Uri.parse(baseUrl);

    var request = http.MultipartRequest('POST', uri);

    // Añadir campos al form-data
    usuarioData.forEach((key, value) {
      if (value != null) {
        request.fields[key] = value.toString();
      }
    });

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201 || response.statusCode == 200) {
        final correo = usuarioData['correo'];

        // Llamar a EnviarCodigoRegistro
        final codigoResponse = await http.post(
          Uri.parse('$baseUrl/EnviarCodigoRegistro'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(correo),
        );

        if (codigoResponse.statusCode == 200) {
          return {
            'exito': true,
            'mensaje': 'Usuario registrado y código enviado.',
            'correo': correo,
          };
        } else {
          return {
            'exito': true,
            'mensaje': 'Usuario registrado, pero error al enviar el código: ${codigoResponse.body}'
          };
        }
      } else {
        return {
          'exito': false,
          'mensaje': 'Error al registrar el usuario: ${response.body}'
        };
      }
    } catch (e) {
      return {
        'exito': false,
        'mensaje': 'Ocurrió un error de red: $e'
      };
    }
  }
}
