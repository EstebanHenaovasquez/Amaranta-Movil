class Categoria {
  final int idCategoria;
  final String nombreCategoria;
  final String descripcion;

  Categoria({
    required this.idCategoria,
    required this.nombreCategoria,
    required this.descripcion,
  });

  factory Categoria.fromJson(Map<String, dynamic> json) => Categoria(
        idCategoria: json['idCategoria'],
        nombreCategoria: json['nombreCategoria'],
        descripcion: json['descripcion'],
      );
}
