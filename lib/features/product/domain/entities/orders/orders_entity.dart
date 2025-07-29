
class OrdersEntity {
  final int id;
  final String serie;
  final int folio;
  final String fecha;
  final int idCliente;
  final ClienteEntity cliente;
  final List<MovimientoEntity> movimientos;

  OrdersEntity({
    required this.id,
    required this.serie,
    required this.folio,
    required this.fecha,
    required this.idCliente,
    required this.cliente,
    required this.movimientos,
  });
  }

class ClienteEntity {
  final int id;
  final String codigo;
  final String cliente;

  ClienteEntity({
    required this.id,
    required this.cliente,
    required this.codigo,
  });

}

class MovimientoEntity {
  final int id;
  final int idDocumento;
  final int cantidad;
  final int idUnidad;
  final double precio;
  final double total;
  final int pendientes;
  final int idProducto;
  final ProductoEntity producto;
  final UnidadEntity unidad;

  MovimientoEntity({
    required this.id,
    required this.idDocumento,
    required this.cantidad,
    required this.idUnidad,
    required this.precio,
    required this.total,
    required this.pendientes,
    required this.idProducto,
    required this.producto,
    required this.unidad,
  });

}

class ProductoEntity {
  final int id;
  final String codigo;
  final String nombre;

  ProductoEntity({
    required this.id,
    required this.codigo,
    required this.nombre,
  });

}

class UnidadEntity {
  final int id;
  final String nombre;
  final String abreviatura;

  UnidadEntity({
    required this.id,
    required this.nombre,
    required this.abreviatura,
  });

}