
import 'package:altera/common/theme/Theme_colors.dart';
import 'package:altera/features/user/presentacion/page/perfil/perfil_controller.dart';
import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:get/get.dart';
class CurvePainter extends CustomPainter {
  CurvePainter();
  
  @override
  void paint(Canvas canvas, Size size) {
    final color1 = Colors.blueAccent.withOpacity(0.05);
    final color2 = Colors.purpleAccent.withOpacity(0.05);
    
    var paint = Paint()
      ..color = color1
      ..style = PaintingStyle.fill;
      
    var path = Path()
      ..moveTo(0, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.3, 
                         size.width * 0.5, size.height * 0.2)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.1, 
                         size.width, size.height * 0.2)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);
    
    canvas.drawPath(path, paint);
    
    paint = Paint()
      ..color = color2
      ..style = PaintingStyle.fill;
      
    path = Path()
      ..moveTo(0, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.25, size.height * 0.7, 
                         size.width * 0.5, size.height * 0.6)
      ..quadraticBezierTo(size.width * 0.75, size.height * 0.5, 
                         size.width, size.height * 0.6)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}