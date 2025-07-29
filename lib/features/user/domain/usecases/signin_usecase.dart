import 'package:altera/features/user/data/models/login_response.dart';
import 'package:altera/features/user/domain/repositories/user_repository.dart';

class SigninUsecase {
  final UserRepository userRepository;

  SigninUsecase({required this.userRepository});

  Future<LoginResponse> signin(String email, String password)  async {
    return await userRepository.signin(email, password);
  }
}