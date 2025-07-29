import 'dart:async';
import 'dart:io';

String convertMessageException({required dynamic error}) {
  switch (error) {
    case SocketException:
      return 'Servicio no disponible intente mas tarde';
    case TimeoutException:
      return 'La peticion tardo mas  de lo usual, intente de nuevo';
    default:
      return error.toString();
  }
}

String cleanExceptionMessage(dynamic e) {
  String message = e.toString();

  // Remover prefijos de "Exception:"
  while (message.trim().startsWith("Exception:")) {
    message = message.trim().replaceFirst("Exception:", "").trim();
  }
  
  // Limpiar otros prefijos comunes
  message = message.replaceAll("Exception:", "").trim();
  message = message.replaceAll("Error de conexión:", "").trim();
  
  // Si el mensaje está vacío después de la limpieza, devolver mensaje por defecto
  if (message.isEmpty) {
    message = "Error desconocido";
  }

  return message;
}
String formatErrorForAlert(String errorMessage) {
  // Si el mensaje es muy largo, lo truncamos para la alerta
  if (errorMessage.length > 200) {
    List<String> lines = errorMessage.split('\n');
    if (lines.length > 1) {
      // Mostrar solo las primeras líneas más importantes
      return '${lines.first}\n\nVer consola para más detalles.';
    } else {
      return '${errorMessage.substring(0, 200)}...';
    }
  }
  return errorMessage;
}