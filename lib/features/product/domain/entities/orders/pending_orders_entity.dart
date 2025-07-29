class PendingOrdersEntity {

  final int id;
  final String serie;
  final int folio;
  final String fecha;
  final String id_cliente; 
  final String pendientes;
  final ClienteEntity clienteEntity;
  PendingOrdersEntity({
    required this.id,
    required this.serie,
    required this.folio,
    required this.fecha,
    required this.id_cliente,
    required this.pendientes,
    required this.clienteEntity
  });

}
class ClienteEntity{
   final int id;
   final String codigo;
   final String cliente;
   ClienteEntity({
    required this.id,
    required this.cliente,
    required this.codigo
   });

}