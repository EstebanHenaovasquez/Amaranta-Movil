import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amaranta/models/categorias.dart';
import 'package:amaranta/config/constants.dart';

class CategoriaService {
  final String baseUrl = AppConfig.apiBaseUrl;

  Future<List<Categoria>> obtenerCategorias() async {
    final response = await http.get(Uri.parse('$baseUrl/CProductos'));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((e) => Categoria.fromJson(e)).toList();
    } else {
      throw Exception('Error al cargar categorías');
    }
  }
}
