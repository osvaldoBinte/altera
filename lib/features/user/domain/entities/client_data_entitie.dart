class UserDataEntity {
  int? id;
  String? nombre;
  String? usuario;
  int? idRol;
  String? correo;
  final String token;
  List<dynamic>? entradas;
  final String photo;
  final AlmacenEntity almacen;

  UserDataEntity({
    this.id,
    this.nombre,
    this.usuario,
    this.idRol,
    this.correo,
    required this.token,
    this.entradas,
    required this.photo,
    required this.almacen,
  });

}

class AlmacenEntity {
  int? id;
  String? codigo;
  String? nombre;

  AlmacenEntity({
    this.id,
    this.codigo,
    this.nombre,
  });
}
