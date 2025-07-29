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

  ProductosController? get productosController {
    try {
      return Get.find<ProductosController>();
    } catch (e) {
      return null;
    }
  }

  final List<Widget> pages = [
    LabelScreen(),
    ProductosPage(),
    PendingOrdersScreen(),
    PerfilScreen(),
  ];

  List<String> get titles => [
    'Inicio',
    'Entrada',
    'Surtir',
    'Perfil'
  ];

  List<IconData> get icons => [
    Icons.home_outlined,
    Icons.local_shipping,
    Icons.inventory_2_outlined,
    Icons.person_outline,
  ];

  List<String?> get assetImages => [
    null,
    'assets/truck.png', // Solo imagen de entrada
    null,
    null,
  ];

  final RxInt selectedIndex = 0.obs;

  void changePage(int index) {
    selectedIndex.value = index;
  }

  void resetForNewSession() {
    selectedIndex.value = 0;
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
            Icons.local_shipping,
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
    isSessionActive.value = true;
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