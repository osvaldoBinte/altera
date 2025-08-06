import 'dart:async';

import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/features/product/presentacion/page/getproducto/labels_page.dart';
import 'package:altera/features/product/presentacion/page/productos/producto_page.dart';
import 'package:altera/features/product/presentacion/page/productos/producto_controller.dart';
import 'package:altera/features/product/presentacion/page/surtir/pending_orders_page.dart';
import 'package:altera/features/user/presentacion/page/perfil/perfil_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxBool forceUpdate = false.obs;
  final RxBool isSessionActive = false.obs;
  final int initialIndex;

  // Constructor que acepta el índice inicial
  HomeController({this.initialIndex = 0});

  ProductosController? get productosController {
    try {
      return Get.find<ProductosController>();
    } catch (e) {
      return null;
    }
  }

  // Lista fija de páginas
  final List<Widget> pages = [
    LabelScreen(),      // Índice 0
    ProductosPage(),    // Índice 1
    PendingOrdersScreen(), // Índice 2
    PerfilScreen(),     // Índice 3
  ];

  List<String> get titles => [
    'Inicio',    // Índice 0
    'Entrada',   // Índice 1
    'Surtir',    // Índice 2
    'Perfil'     // Índice 3
  ];

  List<IconData> get icons => [
    Icons.home_outlined,        // Índice 0
    Icons.local_shipping,       // Índice 1
    Icons.inventory_2_outlined, // Índice 2
    Icons.person_outline,       // Índice 3
  ];

  List<String?> get assetImages => [
    null,                // Índice 0
    'assets/truck.png',  // Índice 1
    null,                // Índice 2
    null,                // Índice 3
  ];

  final RxInt selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void resetForNewSession() {
    selectedIndex.value = initialIndex; // Usar el índice inicial
    isSessionActive.value = true;
    forceUpdate.value = !forceUpdate.value;
  }

  Widget getTabIcon(int index, {double size = 24.0, Color? color}) {
    String? assetPath = assetImages[index];
    if (assetPath != null) {
      return Image.asset(
        assetPath,
        width: size,
        height: size,
        color: color,
        colorBlendMode: color != null ? BlendMode.srcIn : null,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            icons[index],
            size: size,
            color: color,
          );
        },
      );
    } else {
      return Icon(
        icons[index],
        size: size,
        color: color,
      );
    }
  }

  @override
  void onInit() {
    super.onInit();
    // Establecer el índice inicial al inicializar
    selectedIndex.value = initialIndex;
    isSessionActive.value = true;
    print('🏠 HomeController inicializado con índice: $initialIndex (${titles[initialIndex]})');
  }

  void endSession() {
    isSessionActive.value = false;
  }

  @override
  void onClose() {
    endSession();
    super.onClose();
  }
}