// 1. Nueva entidad para Log
class LogEntity {
  final int id;
  final int idEntradaProducto;
  final int idUsuario;
  final int idTipo;
  final String fechaHora;
  final TipoEntity tipo;
  final UsuarioEntity usuario;

  LogEntity({
    required this.id,
    required this.idEntradaProducto,
    required this.idUsuario,
    required this.idTipo,
    required this.fechaHora,
    required this.tipo,
    required this.usuario,
  });
}

// 2. Nueva entidad para Usuario
class UsuarioEntity {
  final int id;
  final String nombre;
  final String usuario;

  UsuarioEntity({
    required this.id,
    required this.nombre,
    required this.usuario,
  });
}

// 3. EntryEntity actualizada con logs
class EntryEntity {
  final int id;
  final int idEntrada;
  final int idProducto;
  final int maquina;
  final String anchoAla;
  final String longitud;
  final String calibre;
  final String piezasPorPallet;
  final String camasPorTarima;
  final String bultosPorCama;
  final String piezasPorBulto;
  final String puntos;
  final String ordenCompra;
  final String observaciones;
  final TipoEntity tipo;
  final ProductEntity producto;
  final List<LogEntity> logs; // NUEVA PROPIEDAD

  EntryEntity({
    required this.id,
    required this.idEntrada,
    required this.idProducto,
    required this.maquina,
    required this.anchoAla,
    required this.longitud,
    required this.calibre,
    required this.piezasPorPallet,
    required this.camasPorTarima,
    required this.bultosPorCama,
    required this.piezasPorBulto,
    required this.puntos,
    required this.ordenCompra,
    required this.observaciones,
    required this.tipo,
    required this.producto,
    required this.logs, // NUEVA PROPIEDAD
  });
}

// 4. TipoEntity actualizada (sin cambios, pero incluida para completitud)
class TipoEntity {
  final int id;
  final String tipo;

  TipoEntity({
    required this.id,
    required this.tipo,
  });
}

// 5. ProductEntity actualizada con id
class ProductEntity {
  final int id;
  final String nombre;
  final String codigo;

  ProductEntity({
    required this.id,
    required this.nombre,
    required this.codigo,
  });
}
