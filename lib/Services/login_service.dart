import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/login_respuesta.dart';
import 'package:amaranta/config/constants.dart';

class LoginService {
  static const String baseUrl =
      '${AppConfig.apiBaseUrl}/Usuarios/Login';
  // http://amarantaapi.somee.com/api/Usuarios/Login

  static Future<LoginRespuesta> login(String correo, String clave) async {
    final url = Uri.parse(baseUrl);

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'correo': correo, 'clave': clave}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    // Si la respuesta incluye un token (campo token o access_token), lo guardamos
    try {
      final prefs = await SharedPreferences.getInstance();
      String? token;
      if (data.containsKey('token')) token = data['token']?.toString();
      if ((token == null || token.isEmpty) &&
          data.containsKey('access_token')) {
        token = data['access_token']?.toString();
      }
      if (token != null && token.isNotEmpty) {
        await prefs.setString('auth_token', token);
      }
    } catch (e) {
      // no bloqueamos el login por errores al guardar token
    }

    return LoginRespuesta.fromJson(data);
  }
}
