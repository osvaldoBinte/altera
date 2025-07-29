import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';

class ApiExceptionCustom implements Exception {
  String message;
  final Response? response;
  List<int>? failedProductIds; // ✅ NUEVO: Para almacenar IDs de productos que fallaron

  ApiExceptionCustom({this.message = '', this.response, this.failedProductIds});

  String getMessage(code) {
    switch (code) {
      case 200:
        return "Petición exitosa";
      case 400:
        return "Error de server";
      case 401:
        return "No autorizado";
      case 404:
        return "Recurso no encontrado";
      case 500:
        return "Error interno del servidor";

      default:
        return "Error desconocido";
    }
  }

  void validateMesage() {
    String errorMessage = '';
    if (response != null && response?.statusCode != 500) {
      if (response!.body.toString() != '') {
        final dataUTF8 = utf8.decode(response!.bodyBytes);
        try {
          final body = jsonDecode(dataUTF8);
          if (body is Map<String, dynamic> && body.containsKey('message')) {
            errorMessage = body['message'];
            
            // ✅ NUEVO: Extraer IDs de productos que fallaron
            if (body.containsKey('data') && body['data'] is List) {
              failedProductIds = List<int>.from(body['data']);
              print('🚨 Productos que fallaron: $failedProductIds');
            }
          } else {
            errorMessage = getMessage(response!.statusCode);
          }
        } catch (e) {
          errorMessage = getMessage(response!.statusCode);
        }
      } else {
        errorMessage = getMessage(response!.statusCode);
      }
    } else if (response == null && errorMessage != '') {
      errorMessage = message;
    } else {
      errorMessage = getMessage(response?.statusCode);
    }
    message = errorMessage;
  }
void validateMesagepallet() {
    String errorMessage = '';
    
    if (response != null && response?.statusCode != 500) {
      if (response!.body.toString() != '') {
        final dataUTF8 = utf8.decode(response!.bodyBytes);
        try {
          final body = jsonDecode(dataUTF8);
          
          // Imprimir para debugging
          print('🔍 Response body decodificado: $body');
          
          if (body is Map<String, dynamic>) {
            // ✅ NUEVO: Manejar errores específicos en el campo 'data'
            if (body.containsKey('data') && body['data'] is List) {
              List<dynamic> dataList = body['data'];
              List<String> specificErrors = [];
              
              for (var item in dataList) {
                if (item is Map<String, dynamic> && item.containsKey('error')) {
                  String productError = '';
                  
                  // Construir mensaje detallado
                  if (item.containsKey('id_producto')) {
                    productError += 'Producto ID ${item['id_producto']}: ';
                  }
                  
                  productError += item['error'];
                  
                  // Agregar detalles adicionales si están disponibles
                  if (item.containsKey('pendientes') && item.containsKey('piezas_por_pallet')) {
                    productError += ' (Pendientes: ${item['pendientes']}, Enviado: ${item['piezas_por_pallet']})';
                  }
                  
                  specificErrors.add(productError);
                }
              }
              
              // Si encontramos errores específicos, usarlos
              if (specificErrors.isNotEmpty) {
                errorMessage = specificErrors.join('\n• ');
                // Agregar el mensaje general si existe
                if (body.containsKey('message')) {
                  errorMessage = '${body['message']}\n\nDetalles:\n• $errorMessage';
                }
              }
              // Si no hay errores específicos pero hay message general
              else if (body.containsKey('message')) {
                errorMessage = body['message'];
              }
              else {
                errorMessage = getMessage(response!.statusCode);
              }
              
              // Extraer IDs de productos que fallaron para uso posterior
              failedProductIds = dataList
                  .where((item) => item is Map<String, dynamic> && item.containsKey('id_producto'))
                  .map<int>((item) => item['id_producto'] as int)
                  .toList();
              
              if (failedProductIds!.isNotEmpty) {
                print('🚨 Productos que fallaron: $failedProductIds');
              }
            }
            // Manejo normal si no hay campo 'data' con errores
            else if (body.containsKey('message')) {
              errorMessage = body['message'];
            }
            else if (body.containsKey('error')) {
              errorMessage = body['error'];
            }
            else if (body.containsKey('errors')) {
              errorMessage = body['errors'].toString();
            }
            else {
              errorMessage = getMessage(response!.statusCode);
            }
          } else {
            errorMessage = getMessage(response!.statusCode);
          }
        } catch (e) {
          print('❌ Error al decodificar JSON del error: $e');
          errorMessage = getMessage(response!.statusCode);
        }
      } else {
        errorMessage = getMessage(response!.statusCode);
      }
    } else if (response == null && message != '') {
      errorMessage = message;
    } else {
      errorMessage = getMessage(response?.statusCode);
    }
    
    message = errorMessage;
    print('✅ Mensaje final de error: $message');
  }

 @override
  String toString() {
    return message; // Solo devolver el mensaje, sin prefijos adicionales
  }
}

String convertMessageException({required dynamic error}) {
  switch (error) {
    case SocketException:
      return 'Servicio no disponible intente mas tarde';
    case ClientException:
      return 'Conexion Cerrada';
    case TimeoutException:
      return 'La peticion tardo mas  de lo usual, intente de nuevo';
    default:
      return error.toString();
  }
}