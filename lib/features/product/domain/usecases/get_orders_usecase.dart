import 'package:altera/features/product/domain/entities/orders/orders_entity.dart';
import 'package:altera/features/product/domain/repositories/product_repository.dart';

class GetOrdersUsecase {
  final ProductRepository productRepository;
  GetOrdersUsecase({required this.productRepository});
    Future<OrdersEntity>  execute({required int id}) async {
   
    return await productRepository.getorders( id: id);
  }
}