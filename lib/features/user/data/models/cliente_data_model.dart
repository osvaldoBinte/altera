import 'package:altera/features/user/domain/entities/client_data_entitie.dart';

class UserDataModel extends UserDataEntity {
  UserDataModel({
    int? id,
    String? nombre,
    String? usuario,
    int? idRol,
    String? correo,
    required String token,
    List<dynamic>? entradas,
    required String photo,
  }) : super(
          id: id,
          nombre: nombre,
          usuario: usuario,
          idRol: idRol,
          correo: correo,
          token: token,
          entradas: entradas,
          photo: photo,
        );

  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      id: json['id'],
      nombre: json['nombre'],
      usuario: json['usuario'],
      idRol: json['id_rol'],
      correo: json['correo'],
      token: json['token'],
      entradas: json['entradas'] ?? [],
      photo: json['photo'] ?? '', 
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'usuario': usuario,
      'id_rol': idRol,
      'correo': correo,
      'token': token,
      'entradas': entradas ?? [],
      'photo': photo,
    };
  }
}
