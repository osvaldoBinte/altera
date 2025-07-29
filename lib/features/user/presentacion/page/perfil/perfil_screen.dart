import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/common/widgets/curve_painter.dart';
import 'package:altera/features/user/presentacion/page/perfil/perfil_controller.dart';
import 'package:altera/features/user/presentacion/page/perfil/perfil_loading.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:get/get.dart';

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({
    super.key,
  });

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  String? imageUrl =
      "https://images.unsplash.com/photo-1506748686214-e9df14d4d9d0"; // O null si no hay imagen

  bool isNotifications = false;
  
  // Obtener el controlador (debe ser inyectado con Get.put() en otro lugar con el usecase)
  PerfilController get controller => Get.find<PerfilController>();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // Mostrar loading personalizado si está cargando
      if (controller.isLoading.value) {
        return Scaffold(
          body: PerfilLoading(),
        );
      }

      // Mostrar error si hay algún error
      if (controller.errorMessage.value.isNotEmpty) {
        return Scaffold(
          body: Container(
            decoration: BoxDecoration(
              gradient: AdminColors.backgroundGradient,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: AdminColors.textSecondaryColor,
                  ),
                  SizedBox(height: 16),
                  Text(
                    controller.errorMessage.value,
                    style: TextStyle(
                      color: AdminColors.textSecondaryColor,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => controller.refreshUserData(),
                    child: Text('Reintentar'),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      return Stack(
        children: [
          // Fondo con gradiente
          Container(
            decoration: BoxDecoration(
              gradient: AdminColors.backgroundGradient,
            ),
          ),
          
          // Overlay de diseño
          Positioned.fill(
            child: CustomPaint(
              painter: CurvePainter(),
            ),
          ),
          
          // Contenido principal
          SafeArea(
            child: RefreshIndicator(
              onRefresh: () => controller.refreshUserData(),
              color: AdminColors.colorAccionButtons,
              child: SingleChildScrollView(
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(height: 30),
                      
                      // Cabecera con foto de perfil
                      _buildProfileHeader(),
                      
                      SizedBox(height: 30),
                      
                      // Estado de suscripción
                      
                      // Información personal
                      _buildPersonalInfo(),
                      
                      SizedBox(height: 40),
                      
                      // Configuraciones
                      _buildSettings(),
                      
                      SizedBox(height: 40),
                      
                      // Pie de página
                      _buildFooter(),
                      
                      SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildProfileHeader() {
    final Color textColor = AdminColors.textPrimaryColor;
    final Color accentColor = AdminColors.colorAccionButtons;
    
    return Column(
      children: [
        // Imagen de perfil con efecto glassmorphism
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: accentColor.withOpacity(0.2),
                blurRadius: 20,
                spreadRadius: 5,
                offset: Offset(0, 10),
              ),
            ],
          ),
            child: CircleAvatar(
            radius: 75,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
              child: Container(
                decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: accentColor.withOpacity(0.5),
                  width: 4,
                ),
                ),
                child: ClipOval(
                child: (controller.photo != null && controller.photo!.isNotEmpty)
                  ? Image.network(
                    controller.photo!,
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                    )
                  : Container(
                    width: 150,
                    height: 150,
                    color: Colors.grey[800],
                    child: Icon(
                      Icons.person,
                      size: 80,
                      color: Colors.grey[600],
                    ),
                    ),
                ),
              ),
              ),
            ),
            ),
          ),
        
        SizedBox(height: 20),
        
        // Nombre del usuario (dinámico)
        Obx(() => Text(
          controller.userName,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: 2,
            fontFamily: 'Roboto',
          ),
        )),
        
        SizedBox(height: 10),
        
        // Email del usuario (dinámico)
        Obx(() => controller.userEmail.isNotEmpty 
          ? Text(
              controller.userEmail,
              style: TextStyle(
                color: AdminColors.textSecondaryColor,
                fontWeight: FontWeight.w400,
                fontSize: 14,
                fontFamily: 'Roboto',
              ),
            )
          : SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _buildSubscriptionStatus() {
    final Color textColor = AdminColors.textPrimaryColor;
    final Color secondaryColor = AdminColors.textSecondaryColor;
    final Color accentColor = AdminColors.colorAccionButtons;
    final Color bgColor = Colors.white.withOpacity(0.1);
    final Color borderColor = Colors.white.withOpacity(0.2);
    
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Texto de suscripción
          Text(
            "INFORMACIÓN PRINCIPAL",
            style: TextStyle(
              color: secondaryColor,
              fontWeight: FontWeight.w500,
              fontSize: 12,
              letterSpacing: 1.5,
              fontFamily: 'Roboto',
            ),
          ),
          
          SizedBox(height: 16),
          
          // ID del usuario (dinámico)
          Obx(() => Text(
            "ID: ${controller.userId}",
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: 18,
              letterSpacing: 1,
              fontFamily: 'Roboto',
            ),
          )),
          
          SizedBox(height: 20),
          
          // Indicador con número de entradas
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Círculo de fondo
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withOpacity(0.3),
                            width: 8,
                          ),
                        ),
                      ),
                      
                      // Número de entradas (dinámico)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Obx(() => Text(
                            "${controller.userData.value?.entradas?.length ?? 0}",
                            style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w800,
                              fontSize: 32,
                              fontFamily: 'Roboto',
                            ),
                          )),
                          Text(
                            "entradas",
                            style: TextStyle(
                              color: secondaryColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  SizedBox(height: 16),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfo() {
    final Color textColor = AdminColors.textPrimaryColor;
    final Color secondaryColor = AdminColors.textSecondaryColor;
    final Color accentColor = AdminColors.colorAccionButtons;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de sección
        Row(
          children: [
            Icon(
              Icons.person_outline,
              color: accentColor,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              "INFORMACIÓN PERSONAL",
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 1.5,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        
        SizedBox(height: 20),
        
        // Lista de datos personales (dinámicos)
        Obx(() => Column(
          children: [
            _buildInfoItem(Icons.badge_outlined, "Nombre completo", controller.userName),
            _buildInfoItem(Icons.person_outline, "Usuario", controller.userData.value?.usuario ?? 'N/A'),
            _buildInfoItem(Icons.email_outlined, "Correo", controller.userEmail),
            _buildInfoItem(Icons.admin_panel_settings_outlined, "Rol", controller.userRole),
          ],
        )),
      ],
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value) {
    final Color textColor = AdminColors.textPrimaryColor;
    final Color secondaryColor = AdminColors.textSecondaryColor;
    final Color iconBgColor = Colors.white.withOpacity(0.1);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          // Icono en contenedor redondeado
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: textColor,
              size: 20,
            ),
          ),
          
          SizedBox(width: 16),
          
          // Textos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: secondaryColor,
                    fontSize: 12,
                    fontFamily: 'Roboto',
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettings() {
    final Color textColor = AdminColors.textPrimaryColor;
    final Color secondaryColor = AdminColors.textSecondaryColor;
    final Color accentColor = AdminColors.colorAccionButtons;
    final Color bgColor = Colors.white.withOpacity(0.1);
    final Color borderColor = Colors.white.withOpacity(0.2);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado de sección
        Row(
          children: [
            Icon(
              Icons.settings_outlined,
              color: accentColor,
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              "CONFIGURACIÓN",
              style: TextStyle(
                color: accentColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
                letterSpacing: 1.5,
                fontFamily: 'Roboto',
              ),
            ),
          ],
        ),
        
        SizedBox(height: 20),
        
        // Container de cerrar sesión
        GestureDetector(
          onTap: () => controller.cerrarSesion(),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderColor),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.logout_outlined,
                      color: textColor,
                      size: 22,
                    ),
                    SizedBox(width: 16),
                    Text(
                      "Cerrar sesión",
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final Color textColor = AdminColors.textSecondaryColor;
    final Color accentColor = AdminColors.colorAccionButtons;
    
    return Column(
      children: [
        Divider(
          color: Colors.white24,
        ),
        SizedBox(height: 20),
        TextButton(
          onPressed: () {},
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.privacy_tip_outlined,
                size: 16,
                color: accentColor,
              ),
              SizedBox(width: 8),
              Text(
                "Políticas de Privacidad",
                style: TextStyle(
                  color: accentColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  fontFamily: 'Roboto',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}