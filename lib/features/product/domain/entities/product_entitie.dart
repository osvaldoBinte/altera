class ProductEntitie {
  final int idProducto;
  final int puntos;
  final int bultos;
  final int unidadesPorBulto;
  final int cantidad;
  final String ordenCompra;

  ProductEntitie(
      { 
      required  this.idProducto,
      required this.puntos,
      required this.bultos,
      required this.unidadesPorBulto,
      required this.cantidad,
      required this.ordenCompra});
}
