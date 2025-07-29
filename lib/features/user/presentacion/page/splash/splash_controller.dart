import 'package:altera/common/services/auth_service.dart';
import 'package:altera/common/settings/routes_names.dart';
import 'package:altera/features/user/domain/usecases/userdata_usecase.dart';
import 'package:get/get.dart';

class SplashController extends GetxController {
  final RxBool isLoading = true.obs;
  
  final AuthService _authService = Get.find<AuthService>();
  
  final UserdataUsecase userdataUsecase;
  
  SplashController({required this.userdataUsecase});
  
  @override
  void onInit() {
    super.onInit();
    
    Future.delayed(const Duration(milliseconds: 2000), () {
      checkUserSession();
    });
  }
  
  Future<void> checkUserSession() async {
    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        try {
          final userData = await userdataUsecase.execute();

          
          if (userData.isNotEmpty) {
            print('✅ Sesión activa: Redirigiendo a Home');
                          await _authService.saveToken(userData.first.token);

            Get.offAllNamed(RoutesNames.homePage);
          } else {
            print('⚠️ Datos de usuario vacíos: Redirigiendo a Login');
            Get.offAllNamed(RoutesNames.loginPage);
          }
        } catch (e) {
          print('❌ Error al obtener datos de usuario: $e');
          Get.offAllNamed(RoutesNames.loginPage);
        }
      } else {
        print('⚠️ No hay sesión activa: Redirigiendo a Login');
        Get.offAllNamed(RoutesNames.loginPage);
      }
    } catch (e) {
      print('❌ Error al verificar sesión: $e');
      Get.offAllNamed(RoutesNames.loginPage);
    } finally {
      isLoading.value = false;
    }
  }
}