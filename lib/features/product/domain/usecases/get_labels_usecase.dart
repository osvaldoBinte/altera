
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'package:altera/features/product/domain/entities/labelEntity/Label_entity.dart';
import 'package:altera/features/product/domain/repositories/product_repository.dart';

class GetLabelsUsecase {
  final ProductRepository repository;

  GetLabelsUsecase({required this.repository});

Future<List<LabelEntity>> getLabels() async {
    return await repository.getLabels();
  }
}