import 'package:altera/features/product/domain/entities/orders/orders_entity.dart';


class OrdersModel extends OrdersEntity {
  OrdersModel({
    required super.id,
    required super.serie,
    required super.folio,
    required super.fecha,
    required super.idCliente,
    required super.cliente,
    required super.movimientos,
  });

  OrdersModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] ?? 0,
          serie: json['serie'] ?? '',
          folio: json['folio'] ?? 0,
          fecha: json['fecha'] ?? '',
          idCliente: json['id_cliente'] ?? 0,
          cliente: json['cliente'] != null 
              ? ClienteModel.fromJson(json['cliente']) 
              : ClienteModel(id: 0, cliente: '', codigo: ''),
          movimientos: (json['movimientos'] as List<dynamic>?)
              ?.map((mov) => MovimientoModel.fromJson(mov))
              .toList() ?? [],
        );

  OrdersModel.fromEntity(OrdersEntity entity)
      : super(
          id: entity.id,
          serie: entity.serie,
          folio: entity.folio,
          fecha: entity.fecha,
          idCliente: entity.idCliente,
          cliente: ClienteModel.fromEntity(entity.cliente),
          movimientos: entity.movimientos
              .map((mov) => MovimientoModel.fromEntity(mov))
              .toList(),
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'serie': serie,
      'folio': folio,
      'fecha': fecha,
      'id_cliente': idCliente,
      'cliente': (cliente as ClienteModel).toJson(),
      'movimientos': movimientos
          .map((mov) => (mov as MovimientoModel).toJson())
          .toList(),
    };
  }
}

class ClienteModel extends ClienteEntity {
  ClienteModel({
    required super.id,
    required super.cliente,
    required super.codigo,
  });

  ClienteModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] ?? 0,
          codigo: json['codigo'] ?? '',
          cliente: json['cliente'] ?? '',
        );

  ClienteModel.fromEntity(ClienteEntity entity)
      : super(
          id: entity.id,
          cliente: entity.cliente,
          codigo: entity.codigo,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'cliente': cliente,
    };
  }
}

class MovimientoModel extends MovimientoEntity {
  MovimientoModel({
    required super.id,
    required super.idDocumento,
    required super.cantidad,
    required super.idUnidad,
    required super.precio,
    required super.total,
    required super.pendientes,
    required super.idProducto,
    required super.producto,
    required super.unidad,
  });

  MovimientoModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] ?? 0,
          idDocumento: json['id_documento'] ?? 0,
          cantidad: json['cantidad'] ?? 0,
          idUnidad: json['id_unidad'] ?? 0,
          precio: (json['precio'] ?? 0).toDouble(),
          total: (json['total'] ?? 0).toDouble(),
          pendientes: json['pendientes'] ?? 0,
          idProducto: json['id_producto'] ?? 0,
          producto: json['producto'] != null 
              ? ProductoModel.fromJson(json['producto']) 
              : ProductoModel(id: 0, codigo: '', nombre: ''),
          unidad: json['unidad'] != null 
              ? UnidadModel.fromJson(json['unidad']) 
              : UnidadModel(id: 0, nombre: '', abreviatura: ''),
        );

  MovimientoModel.fromEntity(MovimientoEntity entity)
      : super(
          id: entity.id,
          idDocumento: entity.idDocumento,
          cantidad: entity.cantidad,
          idUnidad: entity.idUnidad,
          precio: entity.precio,
          total: entity.total,
          pendientes: entity.pendientes,
          idProducto: entity.idProducto,
          producto: ProductoModel.fromEntity(entity.producto),
          unidad: UnidadModel.fromEntity(entity.unidad),
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'id_documento': idDocumento,
      'cantidad': cantidad,
      'id_unidad': idUnidad,
      'precio': precio,
      'total': total,
      'pendientes': pendientes,
      'id_producto': idProducto,
      'producto': (producto as ProductoModel).toJson(),
      'unidad': (unidad as UnidadModel).toJson(),
    };
  }
}

class ProductoModel extends ProductoEntity {
  ProductoModel({
    required super.id,
    required super.codigo,
    required super.nombre,
  });

  ProductoModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] ?? 0,
          codigo: json['codigo'] ?? '',
          nombre: json['nombre'] ?? '',
        );

  ProductoModel.fromEntity(ProductoEntity entity)
      : super(
          id: entity.id,
          codigo: entity.codigo,
          nombre: entity.nombre,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': codigo,
      'nombre': nombre,
    };
  }
}

class UnidadModel extends UnidadEntity {
  UnidadModel({
    required super.id,
    required super.nombre,
    required super.abreviatura,
  });

  UnidadModel.fromJson(Map<String, dynamic> json)
      : super(
          id: json['id'] ?? 0,
          nombre: json['nombre'] ?? '',
          abreviatura: json['abreviatura'] ?? '',
        );

  UnidadModel.fromEntity(UnidadEntity entity)
      : super(
          id: entity.id,
          nombre: entity.nombre,
          abreviatura: entity.abreviatura,
        );

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'abreviatura': abreviatura,
    };
  }
}