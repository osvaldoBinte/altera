import 'package:altera/common/errors/convert_message.dart';
import 'package:altera/common/widgets/custom_alert_type.dart';
import 'package:altera/features/page/home/home_controller.dart';
import 'package:altera/features/product/presentacion/page/productos/producto_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:altera/common/settings/routes_names.dart';
import 'package:altera/common/services/auth_service.dart';
import 'package:altera/features/user/domain/usecases/signin_usecase.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  
  final RxBool isLoading = false.obs;
  final RxBool showPassword = false.obs;
  
  final AuthService _authService = Get.find<AuthService>();
  
  final SigninUsecase signinUsecase;
  
  LoginController({required this.signinUsecase});
  
  void togglePasswordVisibility() {
    showPassword.value = !showPassword.value;
  }
  
  void onLoginTap() async {
    if (!_validateFields()) return;
    
    try {
      isLoading.value = true;
      
      final email = emailController.text.trim();
      final password = passwordController.text.trim();
      
      final loginResponse = await signinUsecase.signin(email, password);
      
      if (loginResponse.success) {
        await _authService.saveToken(loginResponse.token);
        
        _clearFields();
           await _resetControllersForNewSession();
           Get.toNamed(RoutesNames.homePage, arguments: 0);

      } else {
        _showErrorAlert(
          'ACCESO INCORRRECTO',
          loginResponse.message,
          
        );
       
      }
    } catch (e) {
       _showErrorAlert(
          'ACCESO INCORRRECTO',
          cleanExceptionMessage(e),
          
        );
     
    } finally {
      isLoading.value = false;
    }
  }
   Future<void> _resetControllersForNewSession() async {
    print('🔄 Reseteando controllers para nueva sesión...');
    
    try {
      if (Get.isRegistered<HomeController>()) {
        final homeController = Get.find<HomeController>();
        homeController.endSession();
        Get.delete<HomeController>();
        print('🗑️ HomeController eliminado');
      }
      
      if (Get.isRegistered<ProductosController>()) {
        Get.delete<ProductosController>();
        print('🗑️ ProductosController eliminado');
      }
      
      await Future.delayed(Duration(milliseconds: 100));
      
      print('✅ Controllers reseteados para nueva sesión');
      
    } catch (e) {
      print('❌ Error reseteando controllers: $e');
    }
  }
  void _showErrorAlert(String title, String message, {VoidCallback? onDismiss}) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.error,
        onConfirm: onDismiss, 
      );
    }
  }
  bool _validateFields() {
    if (emailController.text.isEmpty) {
    
       _showErrorAlert(
          'Advertencia',
        'Por favor, ingresa tu correo electrónico',
          
        );
      return false;
    }
    
    if (!GetUtils.isEmail(emailController.text)) {
       _showErrorAlert(
          'Advertencia',
        'Por favor, ingresa un correo electrónico válido',
          
        );
    
      return false;
    }
    
    if (passwordController.text.isEmpty) {
     
        _showErrorAlert(
        'Advertencia',
        'Por favor, ingresa tu contraseña',
          
        );
      return false;
    }
    
    return true;
  }
  
  void _clearFields() {
    emailController.clear();
    passwordController.clear();
  }
  
  
  void onRegisterTap() {
    Get.snackbar(
      'Información',
      'Contacta con nosotros para obtener acceso',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
  
  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}