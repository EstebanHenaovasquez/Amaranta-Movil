import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:amaranta/Models/categorias.dart';

class CategoriaService {
  final String baseUrl = 'http://AmarantaAPI.somee.com/api';

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
