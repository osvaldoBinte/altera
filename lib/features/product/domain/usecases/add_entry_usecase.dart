import 'package:altera/features/product/domain/entities/poshProduct/posh_product_entity.dart';
import 'package:altera/features/product/domain/entities/product_entitie.dart';
import 'package:altera/features/product/domain/repositories/product_repository.dart';

class AddEntryUsecase {
  final ProductRepository productRepository;
  AddEntryUsecase({required this.productRepository});
  Future<void> execute(List<PoshProductEntity> poshProductList) async {
    await productRepository.poshEntry(poshProductList);
  }
}
