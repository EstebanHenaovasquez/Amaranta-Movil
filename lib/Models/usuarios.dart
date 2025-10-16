class Usuario {
  final String nombre;
  final String apellido;
  final String correo;

  Usuario({
    required this.nombre,
    required this.apellido,
    required this.correo
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      nombre: json['nombre'],
      apellido: json['apellido'],
      correo: json['correo'],
    );
  }
}
