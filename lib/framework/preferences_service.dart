
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesUser {
  static final PreferencesUser _instancia = PreferencesUser._internal();

  factory PreferencesUser() {
    return _instancia;
  }
  
  PreferencesUser._internal();

  SharedPreferences? _prefs;
  bool _isInitialized = false;

  // ✅ MÉTODO MEJORADO: Asegurar inicialización antes de usar
  Future<void> _ensureInitialized() async {
    if (!_isInitialized || _prefs == null) {
      await initiPrefs();
    }
  }

  Future<void> initiPrefs() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      print('✅ SharedPreferences inicializadas correctamente');
    } catch (e) {
      print('❌ Error al inicializar SharedPreferences: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  // ✅ MÉTODO MEJORADO: Guardar con inicialización automática
  Future<void> savePrefs({
    required dynamic type, 
    required String key, 
    required dynamic value
  }) async {
    try {
      await _ensureInitialized();
      
      if (_prefs == null) {
        print('❌ SharedPreferences no disponibles para guardar');
        return;
      }

      bool success = false;
      switch (type) {
        case bool:
          success = await _prefs!.setBool(key, value);
          break;
        case int:
          success = await _prefs!.setInt(key, value);
          break;
        case String:
          success = await _prefs!.setString(key, value);
          break;
        default:
          print('❌ Tipo no soportado: $type');
          return;
      }
      
      if (success) {
        print('✅ Dato guardado: $key = $value');
      } else {
        print('❌ Error al guardar: $key');
      }
    } catch (e) {
      print('❌ Error en savePrefs: $e');
    }
  }

  // ✅ MÉTODO MEJORADO: Cargar con inicialización automática
  Future<dynamic> loadPrefs({
    required dynamic type, 
    required String key
  }) async {
    try {
      await _ensureInitialized();
      
      if (_prefs == null) {
        print('❌ SharedPreferences no disponibles para cargar');
        return null;
      }

      dynamic result;
      switch (type) {
        case bool:
          result = _prefs!.getBool(key);
          break;
        case int:
          result = _prefs!.getInt(key);
          break;
        case String:
          result = _prefs!.getString(key);
          break;
        default:
          print('❌ Tipo no soportado: $type');
          return null;
      }
      
      print('🔍 Dato cargado: $key = $result');
      return result;
    } catch (e) {
      print('❌ Error en loadPrefs: $e');
      return null;
    }
  }

  Future<void> clearOnePreference({required String key}) async {
    try {
      await _ensureInitialized();
      
      if (_prefs == null) {
        print('❌ SharedPreferences no disponibles para limpiar');
        return;
      }

      bool success = await _prefs!.remove(key);
      if (success) {
        print('✅ Preferencia eliminada: $key');
      } else {
        print('❌ Error al eliminar preferencia: $key');
      }
    } catch (e) {
      print('❌ Error en clearOnePreference: $e');
    }
  }

  Future<void> removePreferences() async {
    try {
      await _ensureInitialized();
      
      if (_prefs == null) {
        print('❌ SharedPreferences no disponibles para limpiar todas');
        return;
      }

      bool success = await _prefs!.clear();
      if (success) {
        print('✅ Todas las preferencias eliminadas');
      } else {
        print('❌ Error al eliminar todas las preferencias');
      }
    } catch (e) {
      print('❌ Error en removePreferences: $e');
    }
  }

  // ✅ NUEVO: Método para verificar si está inicializado
  bool get isInitialized => _isInitialized && _prefs != null;

  // ✅ NUEVO: Método para obtener todas las claves (útil para debugging)
  Future<Set<String>> getAllKeys() async {
    try {
      await _ensureInitialized();
      return _prefs?.getKeys() ?? <String>{};
    } catch (e) {
      print('❌ Error al obtener claves: $e');
      return <String>{};
    }
  }
}