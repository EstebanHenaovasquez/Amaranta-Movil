// services/producto_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amaranta/models/producto.dart';
import 'package:amaranta/config/constants.dart';

class ProductoService {
  final String baseUrl =
      AppConfig.apiBaseUrl; // Reemplaza con tu URL real

  Future<List<Producto>> obtenerProductos() async {
    final response = await http.get(Uri.parse('$baseUrl/Productos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Producto.fromJson(e)).toList();
    } else {
      throw Exception('Error al obtener productos');
    }
  }
}
