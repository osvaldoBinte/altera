import 'package:altera/common/theme/Theme_colors.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';

class InicioController extends GetxController {
  // Instancia de AdminColors
  final AdminColors colores = AdminColors();
  
  // Variables observables
  RxInt currentIndex = 0.obs;
  
  // Función que se pasa desde la pantalla principal para cambiar a la pantalla de rutinas
  final Function() cambioAPantallaRutinas;
  
  // Lista de URLs de imágenes para el carrusel
  final List<String> imageUrls = [
    'https://edit.org/img/blog/gpu-plantillas-gimnasio-gym-fitness-diseno-imagenes.webp',
    'https://img.freepik.com/foto-gratis/estadisticas-actividad-fisica-alrededor-persona_23-2150163358.jpg?ga=GA1.1.1004879157.1745128211&semt=ais_hybrid&w=740'
  ];
  
  // Datos del usuario (podrían venir de una API o base de datos)
  final RxString nombreUsuario = "Mario alfredo".obs;
  final RxInt diasRestantesSuscripcion = 3.obs;
  final RxString rutinaHoy = "hombros".obs;
  
  // Constructor que recibe la función de cambio a pantalla de rutinas
  InicioController({required this.cambioAPantallaRutinas});
  
  // Método para avanzar a la siguiente imagen en el carrusel
  void siguienteImagen() {
    if (currentIndex.value < imageUrls.length - 1) {
      currentIndex.value++;
    }
  }
  
  // Método para retroceder a la imagen anterior en el carrusel
  void anteriorImagen() {
    if (currentIndex.value > 0) {
      currentIndex.value--;
    }
  }
  
  // Método para ir a la sección de todas las suscripciones
  void verTodasSuscripciones() {
    // Navegar a la pantalla de suscripciones
    Get.toNamed('/suscripciones');
  }
  
  // Método para ir a la sección de todos los productos
  void verTodosProductos() {
    // Navegar a la pantalla de productos
    Get.toNamed('/productos');
  }
  
  // Método para ir a la sección de todas las rutinas
  void verTodasRutinas() {
    // Utiliza la función pasada desde la pantalla principal
    cambioAPantallaRutinas();
  }
  
  @override
  void onInit() {
    super.onInit();
    // Aquí podrías cargar datos del usuario, suscripciones, etc.
    cargarDatosUsuario();
  }
  
  // Simula la carga de datos del usuario desde una API o base de datos
  void cargarDatosUsuario() {
    // En una aplicación real, aquí harías una llamada a API o base de datos
    // Por ahora, solo usamos los valores por defecto establecidos arriba
  }
}