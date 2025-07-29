import 'package:altera/features/product/domain/entities/poshProduct/posh_product_entity.dart';

class PoshProductModel extends PoshProductEntity {
  PoshProductModel({required int id})
      : super(id: id);
  factory PoshProductModel.fromJson(Map<String, dynamic> json) {
    return PoshProductModel(
      id: json['id'] ?? 0,
    );
  }
  factory PoshProductModel.fromEntity(PoshProductEntity entity) {
    return PoshProductModel(
      id: entity.id,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
    };
  }
}