import 'package:altera/features/product/domain/entities/orders/pending_orders_entity.dart';
import 'package:altera/features/product/domain/entities/poshProduct/posh_product_entity.dart';
import 'package:altera/features/product/domain/repositories/product_repository.dart';

class GetPendingordersUsecase {
    final ProductRepository repository; 
  GetPendingordersUsecase({required this.repository});
    Future<List<PendingOrdersEntity>> execute({required String date}) async {
      return await repository.getPendingorders(date: date);
      
    }
}