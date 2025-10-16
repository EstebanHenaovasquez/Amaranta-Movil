import 'dart:convert';
import 'package:flutter/services.dart';

class UbicacionLocalService {
  static Future<Map<String, List<String>>> cargarDatos() async {
    final String response = await rootBundle.loadString('assets/data/ubicacion.json');
    final data = jsonDecode(response);
    return Map<String, List<String>>.fromEntries(
      (data as Map).entries.map((e) =>
          MapEntry(e.key.toString(), List<String>.from(e.value))),
    );
  }

  static Future<List<String>> obtenerDepartamentos() async {
    final data = await cargarDatos();
    return data.keys.toList()..sort();
  }

  static Future<List<String>> obtenerMunicipios(String departamento) async {
    final data = await cargarDatos();
    return data[departamento] ?? [];
  }
}
