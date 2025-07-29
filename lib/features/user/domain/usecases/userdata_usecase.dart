import 'package:altera/features/user/domain/entities/client_data_entitie.dart';
import 'package:altera/features/user/domain/repositories/user_repository.dart';

class UserdataUsecase {
    final UserRepository userRepository;
 UserdataUsecase({required this.userRepository});
  Future<List<UserDataEntity>> execute() async {
  

    return await userRepository.userData();
  }
}