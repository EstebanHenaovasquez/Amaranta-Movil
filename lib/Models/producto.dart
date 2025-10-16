// models/producto.dart
class Producto {
  final int? codigoProducto;
  final String nombreProducto;
  final String? imagenUrl;
  final int? stock;
  final double? precio;
  final int? idCategoria;

  Producto({
    this.codigoProducto,
    required this.nombreProducto,
    this.imagenUrl,
    this.stock,
    this.precio,
    this.idCategoria,
  });

  factory Producto.fromJson(Map<String, dynamic> json) {
    return Producto(
      codigoProducto:
          json['codigoProducto'] ?? json['id'] ?? json['idProducto'],
      nombreProducto: json['nombreProducto'] ?? json['nombre'] ?? '',
      imagenUrl: json['imagen'],
      stock: json['stock'],
      precio:
          (json['precio'] != null)
              ? double.tryParse(json['precio'].toString())
              : null,
      idCategoria: json['idCategoria'],
    );
  }
}
