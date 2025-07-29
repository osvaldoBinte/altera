import 'package:altera/features/product/domain/entities/labelEntity/Label_entity.dart';


class LabelModel extends LabelEntity {
 LabelModel({
    required int id,
  required int idEntrada,
 required int idProducto,
  required String producto,
  required int idEntradaProducto,
  required int idUsuario,
  required int idTipo,
  required DateTime fechaHora,
  required TipoEntity tipo,
  required UsuarioEntity usuario,
 }):super(id:id,idProducto: idProducto,producto: producto,idEntradaProducto: idEntradaProducto,idUsuario: idUsuario,idTipo: idTipo,
  fechaHora: fechaHora,tipo: tipo,usuario: usuario,idEntrada: idEntrada);

factory LabelModel.fromJson(Map<String, dynamic> json) {
    return LabelModel(
      id: json['id'],
      idEntrada: json['id_entrada'],
      idProducto: json['id_producto'],
      producto: json['producto'],
      idEntradaProducto: json['id_entrada_producto'],
      idUsuario: json['id_usuario'],
      idTipo: json['id_tipo'],
      fechaHora: DateTime.parse(json['fecha_hora']),
       tipo: json['tipo'] != null ? TipoEntity(
        id: json['tipo']['id'] ?? 0,
        tipo: json['tipo']['tipo'] ?? '',
      ): TipoEntity(id: 0, tipo: ''),

      usuario: json['usuario'] != null ? UsuarioEntity(
        id: json['usuario']['id'] ?? 0,
        nombre: json['usuario']['nombre'] ?? '',
        usuario: json['usuario']['usuario'] ?? '',
      ) : UsuarioEntity(id: 0, nombre: '', usuario: ''),
    );
  }

factory LabelModel.fromEntity(LabelEntity labelEntity) {
  return LabelModel(
    id: labelEntity.id,
    idEntrada: labelEntity.idEntrada,
    idProducto: labelEntity.idProducto,
    producto: labelEntity.producto,
    idEntradaProducto: labelEntity.idEntradaProducto,
    idUsuario: labelEntity.idUsuario,
    idTipo: labelEntity.idTipo,
    fechaHora: labelEntity.fechaHora,
     tipo: TipoEntity(
        id: labelEntity.tipo.id,
        tipo: labelEntity.tipo.tipo,
      ),
      usuario: UsuarioEntity(
        nombre: labelEntity.usuario.nombre,
        usuario: labelEntity.usuario.usuario, id: labelEntity.usuario.id,
      ),
    
  );
}

Map<String, dynamic> toJson() {
  return {
    'id': id,
    'id_entrada': idEntrada,
    'id_producto': idProducto,
    'producto': producto,
    'id_entrada_producto': idEntradaProducto,
    'id_usuario': idUsuario,
    'id_tipo': idTipo,
    'fecha_hora': fechaHora.toIso8601String(),
    'tipo': {
        'id': tipo.id,
        'tipo': tipo.tipo,
      },
     "usuario": {
                    "id": id,
                    "nombre": usuario.nombre,
                    "usuario":usuario.usuario
                }
  };
}
}

