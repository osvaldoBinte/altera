import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'package:altera/features/product/domain/repositories/product_repository.dart';

class GetProductoUsecase {
  final ProductRepository repository;

  GetProductoUsecase({required this.repository});

  Future<List<EntryEntity>> execute(String idProducto) async {
    return await repository.getEntry(idProducto);
  }
}