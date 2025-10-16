import 'usuarios.dart';

class LoginRespuesta {
  final bool exito;
  final String mensaje;
  final Usuario? usuario;

  LoginRespuesta({
    required this.exito,
    required this.mensaje,
    this.usuario,
  });

  factory LoginRespuesta.fromJson(Map<String, dynamic> json) {
    return LoginRespuesta(
      exito: json['exito'],
      mensaje: json['mensaje'],
      usuario: json['usuario'] != null ? Usuario.fromJson(json['usuario']) : null,
    );
  }
}
