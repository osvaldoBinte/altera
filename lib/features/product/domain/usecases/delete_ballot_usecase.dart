import 'package:altera/features/product/domain/entities/poshProduct/posh_product_entity.dart';
import 'package:altera/features/product/domain/repositories/product_repository.dart';

class DeleteBallotUsecase {
  ProductRepository productRepository;
  DeleteBallotUsecase({required this.productRepository});
  Future<void> execute(List<PoshProductEntity> poshProductList){
    return productRepository.deleteBallot(poshProductList);
  }
}
