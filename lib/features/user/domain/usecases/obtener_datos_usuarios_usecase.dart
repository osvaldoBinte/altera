
import 'package:altera/features/user/domain/entities/client_data_entitie.dart';
import 'package:altera/features/user/domain/repositories/user_repository.dart';

class ObtenerDatosUsuariosUsecase {
  final UserRepository userRepository;

  ObtenerDatosUsuariosUsecase(this.userRepository);

  Future<UserDataEntity>  execute(String codigoQr) async {
    return await userRepository.obtenerDatosUsuarios(codigoQr);
  }
}