
import 'package:altera/features/user/data/models/login_response.dart';
import 'package:altera/features/user/domain/entities/client_data_entitie.dart';

abstract class UserRepository {
  Future<UserDataEntity> obtenerDatosUsuarios( String codigoQr);
  Future<LoginResponse> signin(String email, String password);
  Future<List<UserDataEntity>> userData();
}