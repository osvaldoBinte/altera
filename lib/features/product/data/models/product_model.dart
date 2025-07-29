import 'package:altera/features/product/domain/entities/product_entitie.dart';

class ProductModel extends ProductEntitie {
 ProductModel({
    required int idProducto,
  required int puntos,
  required int bultos,
  required int unidadesPorBulto,
  required int cantidad,
  required String ordenCompra, 
 }):super(idProducto:idProducto,puntos: puntos,bultos: bultos,unidadesPorBulto: unidadesPorBulto,cantidad: cantidad,ordenCompra: ordenCompra );

 factory ProductModel.fromJson(Map<String,dynamic> json){
  return ProductModel(
    idProducto: json['idProducto']??0,
    puntos: json['puntos']??0,
    bultos: json['bultos']??0,
    unidadesPorBulto: json['unidadesPorBulto']??0,
    cantidad: json['cantidad'] ?? 0,
    ordenCompra: json['ordenCompra']??''
  );
 }

 factory ProductModel.fromEntity(ProductEntitie productEntitie){
  return ProductModel(idProducto: productEntitie.idProducto, puntos: productEntitie.puntos, bultos: productEntitie.bultos, unidadesPorBulto: productEntitie.unidadesPorBulto,
   cantidad: productEntitie.cantidad, ordenCompra: productEntitie.ordenCompra);
 }

 Map<String, dynamic> toJson(){
  return {
    'idProducto': idProducto,
    'puntos': puntos,
    'bultos': bultos,
    'unidadesPorBulto':unidadesPorBulto,
    'cantidad': cantidad,
    'ordenCompra':ordenCompra
  };
 }
}

