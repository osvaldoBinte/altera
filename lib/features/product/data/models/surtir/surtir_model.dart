import 'package:altera/features/product/domain/entities/surtir/surtir_entity.dart';

class SurtirModel extends SurtirEntity {
   SurtirModel({
    required super.id,
    required super.piezas_por_pallet,
    required super.id_producto,
  });
factory SurtirModel.fromJson(Map<String, dynamic> json) {
    return SurtirModel(
      id: json['id'] ?? 0,
      piezas_por_pallet: json['piezas_por_pallet'],

      id_producto: json['id_producto'] ,
    );
  }
  factory SurtirModel.fromEntity(SurtirEntity entity) {
    return SurtirModel(
      id: entity.id,
      piezas_por_pallet: entity.piezas_por_pallet,
      id_producto: entity.id_producto,

    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'piezas_por_pallet' : piezas_por_pallet,
      'id_producto':id_producto
    };
  }
}