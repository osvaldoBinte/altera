import 'package:altera/common/constants/constants.dart';
import 'package:altera/common/errors/convert_message.dart';
import 'package:altera/features/product/domain/entities/orders/pending_orders_entity.dart';
import 'package:altera/features/product/domain/entities/orders/orders_entity.dart';
import 'package:altera/features/product/domain/entities/getEntryEntity/get_entry_entity.dart';
import 'package:altera/features/product/domain/entities/surtir/surtir_entity.dart';
import 'package:altera/features/product/domain/usecases/get_orders_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_pendingorders_usecase.dart';
import 'package:altera/features/product/domain/usecases/get_producto_usecase.dart';
import 'package:altera/features/product/domain/usecases/add_exit_usecase.dart';
import 'package:altera/common/widgets/custom_alert_type.dart';
import 'package:altera/framework/preferences_service.dart';
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert'; // Para JSON encoding/decoding

class PendingOrdersController extends GetxController {
  final GetPendingordersUsecase getPendingOrdersUseCase;
  final GetOrdersUsecase getOrdersUsecase;
  final GetProductoUsecase getProductoUsecase;
  final AddExitUsecase addExitUsecase;

  PendingOrdersController({
    required this.getPendingOrdersUseCase, 
    required this.getOrdersUsecase,
    required this.getProductoUsecase,
    required this.addExitUsecase,
  });

  // Estados reactivos existentes
  final RxList<PendingOrdersEntity> _pendingOrders = <PendingOrdersEntity>[].obs;
  final RxList<PendingOrdersEntity> _filteredOrders = <PendingOrdersEntity>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _errorMessage = ''.obs;
  final RxString _searchQuery = ''.obs;
  final Rx<DateTime> _selectedDate = DateTime(
  DateTime.now().year - 1,
  DateTime.now().month,
  DateTime.now().day
).obs;
  final TextEditingController _dateController = TextEditingController();

  // Estados para los detalles de la orden
  final Rx<OrdersEntity?> _selectedOrder = Rx<OrdersEntity?>(null);
  final RxBool _isLoadingOrderDetails = false.obs;
  final RxString _orderDetailsError = ''.obs;

  // MODIFICADO: Mapa para almacenar productos escaneados por orden
  final RxMap<int, List<EntryEntity>> _productosEscaneadosPorOrden = <int, List<EntryEntity>>{}.obs;
  final RxBool _isScanning = false.obs;
  final RxBool _isTorchOn = false.obs;
  final RxBool _isProcessingSurtido = false.obs;
  Rx<MobileScannerController?> qrScannerController = Rx<MobileScannerController?>(null);
  
  // NUEVO: Para manejar la orden actual
  final RxInt _currentOrderId = 0.obs;
  
  String? _lastScannedQR;
  DateTime? _lastScanTime;
  final int _scanCooldownMs = 2000;

  // Getters existentes
  List<PendingOrdersEntity> get pendingOrders => _pendingOrders;
  List<PendingOrdersEntity> get filteredOrders => _filteredOrders;
  bool get isLoading => _isLoading.value;
  String get errorMessage => _errorMessage.value;
  String get searchQuery => _searchQuery.value;
  DateTime get selectedDate => _selectedDate.value;
  TextEditingController get dateController => _dateController;
  OrdersEntity? get selectedOrder => _selectedOrder.value;
  bool get isLoadingOrderDetails => _isLoadingOrderDetails.value;
  String get orderDetailsError => _orderDetailsError.value;

  // MODIFICADO: Getter para productos escaneados de la orden actual
  List<EntryEntity> get productosEscaneados => 
      _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
  
  bool get isScanning => _isScanning.value;
  bool get isTorchOn => _isTorchOn.value;
  bool get isProcessingSurtido => _isProcessingSurtido.value;

  // Estadísticas computadas
  int get totalOrders => _pendingOrders.length;
  int get filteredOrdersCount => _filteredOrders.length;
  final Map<int, TextEditingController> _textControllers = {};

  @override
  void onInit() {
    super.onInit();
    _updateDateController();
    _cargarProductosEscaneadosGuardados();
    loadPendingOrders();
  }
  TextEditingController getControllerForProduct(EntryEntity producto) {
    if (!_textControllers.containsKey(producto.id)) {
      _textControllers[producto.id] = TextEditingController(
        text: producto.piezasPorPallet.toString()
      );
    }
    return _textControllers[producto.id]!;
  }
 void clearController(int productId) {
    if (_textControllers.containsKey(productId)) {
      _textControllers[productId]?.dispose();
      _textControllers.remove(productId);
    }
  }   void clearAllControllers() {
    for (var controller in _textControllers.values) {
      controller.dispose();
    }
    _textControllers.clear();
  }
  @override
  void onClose() {
        clearAllControllers();

    _dateController.dispose();
    _guardarProductosEscaneados();
    if (qrScannerController.value != null) {
      qrScannerController.value!.dispose();
    }
    super.onClose();
  }

  Future<void> _guardarProductosEscaneados() async {
    try {
      final Map<String, dynamic> productosParaGuardar = {};
      
      for (var entry in _productosEscaneadosPorOrden.entries) {
        final orderId = entry.key.toString();
        final productos = entry.value;
        
        final productosJson = productos.map((producto) => _entryEntityToJson(producto)).toList();
        productosParaGuardar[orderId] = productosJson;
      }
      
      final jsonString = jsonEncode(productosParaGuardar);
       PreferencesUser().savePrefs(
        type: String, 
        key: AppConstants.productosescaneados, 
        value: jsonString
      );
      
      print('💾 Productos escaneados guardados en SharedPreferences');
    } catch (e) {
      print('❌ Error al guardar productos escaneados: $e');
    }
  }

  Future<void> _cargarProductosEscaneadosGuardados() async {
    try {
      final jsonString = await PreferencesUser().loadPrefs(
        type: String, 
        key:  AppConstants.productosescaneados
      );
      
      if (jsonString != null && jsonString.isNotEmpty) {
        final Map<String, dynamic> productosGuardados = jsonDecode(jsonString);
        
        for (var entry in productosGuardados.entries) {
          final orderId = int.tryParse(entry.key);
          if (orderId != null) {
            final productosJson = entry.value as List<dynamic>;
            final productos = productosJson
                .map((json) => _entryEntityFromJson(json))
                .toList();
            
            _productosEscaneadosPorOrden[orderId] = productos;
          }
        }
        
        print('📂 Productos escaneados cargados desde SharedPreferences');
        print('📊 Órdenes con productos: ${_productosEscaneadosPorOrden.keys.length}');
      }
    } catch (e) {
      print('❌ Error al cargar productos escaneados: $e');
    }
  }

  // NUEVO: Método para establecer la orden actual
  void _setCurrentOrderId(int orderId) {
    _currentOrderId.value = orderId;
    print('🔄 Orden actual establecida: $orderId');
    
    // Inicializar lista vacía si no existe
    if (!_productosEscaneadosPorOrden.containsKey(orderId)) {
      _productosEscaneadosPorOrden[orderId] = <EntryEntity>[];
    }
    
    // Trigger refresh para actualizar la UI
    _productosEscaneadosPorOrden.refresh();
  }

  // Métodos existentes (mantener todos los métodos anteriores)
  void _updateDateController() {
    _dateController.text = formatDateForInput(_selectedDate.value);
  }

  String formatDateForInput(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  String formatDateForApi(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  void changeSelectedDate(DateTime date) {
    _selectedDate.value = date;
    _updateDateController();
    loadPendingOrders();
  }

  Future<void> selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.value,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF3F72AF),
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Color(0xFF2C3E50),
            ),
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate.value) {
      changeSelectedDate(picked);
    }
  }

  void setToday() {
    changeSelectedDate(DateTime.now());
  }

  Future<void> loadPendingOrders() async {
    try {
      _isLoading.value = true;
      _errorMessage.value = '';
      
      final dateString = formatDateForApi(_selectedDate.value);
      final orders = await getPendingOrdersUseCase.execute(date: dateString);
      
      _pendingOrders.value = orders;
      _filteredOrders.value = orders;
      
    } catch (e) {
      _errorMessage.value = 'Error al cargar las órdenes: ${e.toString()}';
      debugPrint('Error loading pending orders: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  void searchOrders(String query) {
    _searchQuery.value = query;
    
    if (query.isEmpty) {
      _filteredOrders.value = _pendingOrders;
    } else {
      final filteredList = _pendingOrders.where((order) {
        final searchTerm = query.toLowerCase();
        return order.serie.toLowerCase().contains(searchTerm) ||
               order.folio.toString().contains(searchTerm) ||
               order.clienteEntity.cliente.toLowerCase().contains(searchTerm) ||
               order.clienteEntity.codigo.toLowerCase().contains(searchTerm) ||
               order.fecha.toLowerCase().contains(searchTerm);
      }).toList();
      
      _filteredOrders.value = filteredList;
    }
  }

  void clearSearch() {
    _searchQuery.value = '';
    _filteredOrders.value = _pendingOrders;
  }

  Future<void> refreshOrders() async {
    await loadPendingOrders();
  }

  void filterByClient(String clientCode) {
    if (clientCode.isEmpty) {
      _filteredOrders.value = _pendingOrders;
    } else {
      final filteredList = _pendingOrders.where((order) {
        return order.clienteEntity.codigo == clientCode;
      }).toList();
      
      _filteredOrders.value = filteredList;
    }
  }

  void sortByDate({bool ascending = true}) {
    final sortedList = List<PendingOrdersEntity>.from(_filteredOrders);
    sortedList.sort((a, b) {
      final dateA = DateTime.tryParse(a.fecha) ?? DateTime.now();
      final dateB = DateTime.tryParse(b.fecha) ?? DateTime.now();
      return ascending ? dateA.compareTo(dateB) : dateB.compareTo(dateA);
    });
    _filteredOrders.value = sortedList;
  }

  void sortByFolio({bool ascending = true}) {
    final sortedList = List<PendingOrdersEntity>.from(_filteredOrders);
    sortedList.sort((a, b) {
      return ascending ? a.folio.compareTo(b.folio) : b.folio.compareTo(a.folio);
    });
    _filteredOrders.value = sortedList;
  }

  Color getPendingColor(String pendientes) {
    final count = int.tryParse(pendientes) ?? 0;
    if (count == 0) return Colors.green;
    if (count <= 5) return Colors.orange;
    return Colors.red;
  }

  String formatDate(String fecha) {
    try {
      final date = DateTime.parse(fecha);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
    } catch (e) {
      return fecha;
    }
  }

  void clearError() {
    _errorMessage.value = '';
  }

  // MODIFICADO: Establecer la orden actual al cargar detalles
  Future<void> loadOrderDetails(int orderId) async {
    try {
      _isLoadingOrderDetails.value = true;
      _orderDetailsError.value = '';
      _selectedOrder.value = null;
      
      // Establecer la orden actual
      _setCurrentOrderId(orderId);
      
      final orderDetails = await getOrdersUsecase.execute(id: orderId);
      _selectedOrder.value = orderDetails;
      
      print('📋 Detalles de orden cargados para ID: $orderId');
      print('📦 Productos escaneados para esta orden: ${productosEscaneados.length}');
      
    } catch (e) {
      _orderDetailsError.value = 'Error al cargar los detalles: ${e.toString()}';
      debugPrint('Error loading order details: $e');
    } finally {
      _isLoadingOrderDetails.value = false;
    }
  }

  // MODIFICADO: No limpiar productos escaneados al cambiar de orden
  void clearOrderDetails() {
    _selectedOrder.value = null;
    _orderDetailsError.value = '';
    _isLoadingOrderDetails.value = false;
    _currentOrderId.value = 0;
    // NO limpiamos productos escaneados aquí
  }

  double calculateOrderTotal(OrdersEntity order) {
    return order.movimientos.fold(0.0, (sum, movimiento) => sum + movimiento.total);
  }

  int getTotalPendientes(OrdersEntity order) {
    return order.movimientos.fold(0, (sum, movimiento) => sum + movimiento.pendientes);
  }

  String formatPrice(double price) {
    return '\$${price.toStringAsFixed(2)}';
  }

  // MÉTODOS DE ESCANEO QR (mantener funcionalidad)
  void iniciarEscaneoQR() {
    _isScanning.value = true;
    _lastScannedQR = null;
    _lastScanTime = null;
    if (qrScannerController.value == null) {
      qrScannerController.value = MobileScannerController(
        detectionSpeed: DetectionSpeed.normal,
        facing: CameraFacing.back,
        torchEnabled: false,
        formats: [BarcodeFormat.qrCode],
      );
    }
  }

  void detenerEscaneoQR() {
    _isScanning.value = false;
    _lastScannedQR = null;
    _lastScanTime = null;
    if (qrScannerController.value != null) {
      qrScannerController.value!.dispose();
      qrScannerController.value = null;
    }
  }

  void toggleTorch() {
    if (qrScannerController.value != null) {
      qrScannerController.value!.toggleTorch();
      _isTorchOn.value = !_isTorchOn.value;
    }
  }
  
  void switchCamera() {
    if (qrScannerController.value != null) {
      qrScannerController.value!.switchCamera();
    }
  }

  void onQRCodeDetected(String qrData) async {
    try {
      print('🔍 QR Data detectado para surtir: "$qrData"');
      DateTime now = DateTime.now();
      if (_lastScannedQR == qrData && _lastScanTime != null) {
        int timeDiff = now.difference(_lastScanTime!).inMilliseconds;
        if (timeDiff < _scanCooldownMs) {
          print('⏰ QR duplicado ignorado (cooldown: ${timeDiff}ms)');
          return; 
        }
      }
      _lastScannedQR = qrData;
      _lastScanTime = now;
      int id = int.parse(qrData.trim());
      print('🔍 ID parseado para surtir: $id');
      await _agregarProductoEscaneado(id.toString());
      detenerEscaneoQR();
    } catch (e) {
      print('❌ Error al parsear QR para surtir: $e');
      _showErrorAlert('QR Inválido', 'El código QR debe contener solo números');
    }
  }
Future<void> _agregarProductoEscaneado(String idStr) async {
  try {
    if (_currentOrderId.value == 0) {
      _showErrorAlert('Error', 'No hay una orden seleccionada');
      return;
    }

    if (_selectedOrder.value == null) {
      _showErrorAlert('Error', 'No se encontraron detalles de la orden');
      return;
    }

    int id = int.parse(idStr);
    print('🔍 Buscando producto para surtir con ID: $id (Orden: ${_currentOrderId.value})');
    
    List<EntryEntity> productosDisponibles = await getProductoUsecase.execute(id.toString());
    print('🔍 Productos encontrados para surtir: ${productosDisponibles.length}');
    
    if (productosDisponibles.isNotEmpty) {
      EntryEntity productoDisponible = productosDisponibles.first;
      print('🔍 Producto encontrado para surtir - ID: ${productoDisponible.id}');
      
      // VALIDACIÓN 1: Verificar si el tipo es diferente a 2
      if (productoDisponible.tipo.id != 2) {
        print('❌ Papeleta no cumple con los requisitos - Tipo: ${productoDisponible.tipo.id} (se requiere tipo 2)');
        _showErrorAlert('Papeleta no válida', 'Papeleta no cumple con los requisitos');
        return;
      }
      
      // VALIDACIÓN 2: Verificar si el producto está en los movimientos de la orden
      bool productoEstaEnOrden = _selectedOrder.value!.movimientos.any((movimiento) => 
        movimiento.producto.id == productoDisponible.producto?.id
      );
      
      if (!productoEstaEnOrden) {
        print('❌ Producto no pertenece a esta orden - Producto ID: ${productoDisponible.producto?.id}');
        print('📋 Productos válidos en la orden: ${_selectedOrder.value!.movimientos.map((m) => m.producto.id).toList()}');
        _showErrorAlert('Producto no válido', 'Este producto no pertenece a la orden seleccionada');
        return;
      }
      
      // Obtener la lista actual de productos para esta orden
      List<EntryEntity> productosActuales = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
      
      int index = productosActuales.indexWhere((p) => p.id == productoDisponible.id);
      if (index >= 0) {
        _showErrorAlert('Ups', 'Producto ya escaneado en esta orden');
      } else {
        // Agregar a la lista de la orden actual
        productosActuales.add(productoDisponible);
        _productosEscaneadosPorOrden[_currentOrderId.value] = productosActuales;
        _productosEscaneadosPorOrden.refresh();
        
        // Guardar en SharedPreferences
        await _guardarProductosEscaneados();
        
        print('✅ Producto agregado para surtir en orden ${_currentOrderId.value}. Total escaneados: ${productosActuales.length}');
      }
    } else {
      print('❌ No se encontraron productos para surtir con ID: $id');
      _showErrorAlert('Ups', 'Producto no encontrado');
    }
  } catch (e) {
    print('❌ Error al procesar el producto para surtir: $e');
    _showErrorAlert('Ups', 'No se pudo procesar el producto $e');
  }
}

  // MODIFICADO: Remover producto de la orden actual
  void removerProductoEscaneado(EntryEntity producto) {
    if (_currentOrderId.value == 0) return;
    
    List<EntryEntity> productosActuales = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
    productosActuales.remove(producto);
    _productosEscaneadosPorOrden[_currentOrderId.value] = productosActuales;
    _productosEscaneadosPorOrden.refresh();
    
    // Guardar cambios
    _guardarProductosEscaneados();
    
    print('🗑️ Producto removido de orden ${_currentOrderId.value}. Quedan: ${productosActuales.length}');
  }

  // MODIFICADO: Limpiar productos de la orden actual
  void limpiarProductosEscaneados() {
    if (_currentOrderId.value == 0) return;
    
    _productosEscaneadosPorOrden[_currentOrderId.value] = <EntryEntity>[];
    _productosEscaneadosPorOrden.refresh();
    
    // Guardar cambios
    _guardarProductosEscaneados();
    
    print('🧹 Productos escaneados limpiados para orden ${_currentOrderId.value}');
  }

  // NUEVO: Método para limpiar productos de una orden específica
  void limpiarProductosEscaneadosDeOrden(int orderId) {
    _productosEscaneadosPorOrden[orderId] = <EntryEntity>[];
    _productosEscaneadosPorOrden.refresh();
    
    // Guardar cambios
    _guardarProductosEscaneados();
    
    print('🧹 Productos escaneados limpiados para orden específica: $orderId');
  }

  // NUEVO: Método para obtener productos escaneados de una orden específica
  List<EntryEntity> getProductosEscaneadosDeOrden(int orderId) {
    return _productosEscaneadosPorOrden[orderId] ?? [];
  }

  // NUEVO: Método para verificar si una orden tiene productos escaneados
  bool tieneProductosEscaneados(int orderId) {
    final productos = _productosEscaneadosPorOrden[orderId] ?? [];
    return productos.isNotEmpty;
  }

  // NUEVO: Método para obtener el conteo de productos escaneados por orden
  int getConteoProductosEscaneados(int orderId) {
    final productos = _productosEscaneadosPorOrden[orderId] ?? [];
    return productos.length;
  }
  
  
  Future<void> procesarSurtido(PendingOrdersEntity order) async {
  try {
    _isProcessingSurtido.value = true;
    
    final productosEscaneadosOrden = _productosEscaneadosPorOrden[order.id] ?? [];
    
    if (productosEscaneadosOrden.isEmpty) {
      _showErrorAlert('Lista vacía', 'No hay productos escaneados para surtir en esta orden.');
      return;
    }
    
    if (_selectedOrder.value == null) {
      _showErrorAlert('Error', 'No se encontraron detalles de la orden.');
      return;
    }
    
    // Crear la lista de entidades SurtirEntity
    List<SurtirEntity> surtirList = [];
    
    for (EntryEntity producto in productosEscaneadosOrden) {
      int piezasEditadas = int.tryParse(producto.piezasPorPallet) ?? 0;
      
      if (piezasEditadas <= 0) {
        _showErrorAlert('Valor inválido', 
          'El producto ${producto.producto?.nombre ?? 'ID: ${producto.id}'} tiene un valor inválido de piezas por pallet: $piezasEditadas');
        return;
      }
      
      SurtirEntity surtirEntity = SurtirEntity(
        id: producto.id,
        piezas_por_pallet: piezasEditadas,
        id_producto: producto.idProducto,
      );
      
      surtirList.add(surtirEntity);
      
      print('📦 Papeleta ID ${producto.id} - Producto ID ${producto.idProducto} (${producto.producto?.nombre}): piezas_por_pallet = $piezasEditadas');
    }
    
    print('📦 Enviando ${surtirList.length} productos al surtir con piezas_por_pallet validadas');
    
    await addExitUsecase.execute(surtirList, order.id.toString());
    _showSuccessAlert('¡Éxito!', 'Surtido procesado correctamente');
    
    limpiarProductosEscaneadosDeOrden(order.id);
    await loadOrderDetails(order.id);
    await loadPendingOrders();
    
  } catch (e) {
    print('❌ Error al procesar surtido: $e');
    
    // ✅ USAR cleanExceptionMessage para mostrar un mensaje más limpio
    String cleanMessage = cleanExceptionMessage(e);
    _showErrorAlert('Error al procesar surtido', cleanMessage);
    
  } finally {
    _isProcessingSurtido.value = false;
  }
}
  void _showErrorAlert(String title, String message) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.error,
      );
    }
  }

  void _showSuccessAlert(String title, String message) {
    if (Get.context != null) {
      showCustomAlert(
        context: Get.context!,
        title: title,
        message: message,
        confirmText: 'Aceptar',
        type: CustomAlertType.success,
      );
    }
  }

  int getTotalCantidadMovimientos() {
    if (_selectedOrder.value == null) return 0;
    
    return _selectedOrder.value!.movimientos.fold(0, (sum, movimiento) {
      return sum + movimiento.cantidad;
    });
  }

  // MODIFICADO: Calcular total de piezas por pallet de la orden actual
  int getTotalPiezasPorPalletEscaneados() {
    final productosEscaneadosOrden = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
    return productosEscaneadosOrden.fold(0, (sum, producto) {
      final piezas = int.tryParse(producto.piezasPorPallet) ?? 0;
      return sum + piezas;
    });
  }

  Map<String, int> getResumenTotales() {
    final productosEscaneadosOrden = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
    return {
      'totalCantidadMovimientos': getTotalCantidadMovimientos(),
      'totalPiezasPalletEscaneados': getTotalPiezasPorPalletEscaneados(),
      'productosEscaneados': productosEscaneadosOrden.length,
      'movimientosOrden': _selectedOrder.value?.movimientos.length ?? 0,
    };
  }

  String formatearNumero(int numero) {
    final formatter = NumberFormat('#,###', 'en_US');
    return formatter.format(numero);
  }

  // MODIFICADO: Actualizar piezas por pallet en la orden actual
   void actualizarPiezasPorPallet(EntryEntity producto, String nuevasPiezas) {
    try {
      if (_currentOrderId.value == 0) return;
      
      final int piezasEditadas = int.tryParse(nuevasPiezas) ?? 0;
      
      if (piezasEditadas < 0) {
        _showErrorAlert('Valor inválido', 'Las piezas por pallet no pueden ser negativas');
        return;
      }
      
      final int piezasOriginales = int.tryParse(producto.piezasPorPallet) ?? 0;
      
      List<EntryEntity> productosActuales = _productosEscaneadosPorOrden[_currentOrderId.value] ?? [];
      
      final index = productosActuales.indexWhere((p) => p.id == producto.id);
      
      if (index != -1) {
        final productoActualizado = EntryEntity(
          id: producto.id,
          idEntrada: producto.idEntrada,
          idProducto: producto.idProducto,
          maquina: producto.maquina,
          anchoAla: producto.anchoAla,
          longitud: producto.longitud,
          calibre: producto.calibre,
          piezasPorPallet: piezasEditadas.toString(), 
          camasPorTarima: producto.camasPorTarima,
          bultosPorCama: producto.bultosPorCama,
          piezasPorBulto: producto.piezasPorBulto,
          puntos: producto.puntos,
          ordenCompra: producto.ordenCompra,
          observaciones: producto.observaciones,
          tipo: producto.tipo,
          producto: producto.producto,
          logs: producto.logs,
        );
        
        // Actualizar la lista
        productosActuales[index] = productoActualizado;
        _productosEscaneadosPorOrden[_currentOrderId.value] = productosActuales;
        
        // Guardar cambios
        _guardarProductosEscaneados();
        
        print('✅ Piezas por pallet actualizadas para papeleta ID ${producto.id}: $piezasEditadas (original: $piezasOriginales)');
        print('📊 Nuevo total de piezas por pallet escaneadas: ${getTotalPiezasPorPalletEscaneados()}');
      }
    } catch (e) {
      print('❌ Error al actualizar piezas por pallet: $e');
      _showErrorAlert('Error', 'No se pudo actualizar el valor');
    }
  }

  // NUEVOS MÉTODOS PARA GESTIÓN AVANZADA

  // Método para limpiar todas las órdenes
  void limpiarTodasLasOrdenes() {
    
    _productosEscaneadosPorOrden.clear();
    _productosEscaneadosPorOrden.refresh();
    _guardarProductosEscaneados();
    print('🧹 Todas las órdenes con productos escaneados han sido limpiadas');
  }

  // Método para obtener estadísticas globales
  Map<String, dynamic> getEstadisticasGlobales() {
    int totalOrdenes = _productosEscaneadosPorOrden.length;
    int totalProductos = 0;
    int totalPiezas = 0;

    for (var productos in _productosEscaneadosPorOrden.values) {
      totalProductos += productos.length;
      for (var producto in productos) {
        totalPiezas += int.tryParse(producto.piezasPorPallet) ?? 0;
      }
    }

    return {
      'ordenesConProductos': totalOrdenes,
      'totalProductosEscaneados': totalProductos,
      'totalPiezasEscaneadas': totalPiezas,
      'promedioProductosPorOrden': totalOrdenes > 0 ? (totalProductos / totalOrdenes).toStringAsFixed(1) : '0',
    };
  }

  // Método para exportar datos (para debugging o backup)
  String exportarDatosEscaneados() {
    try {
      final Map<String, dynamic> datosExport = {
        'timestamp': DateTime.now().toIso8601String(),
        'totalOrdenes': _productosEscaneadosPorOrden.length,
        'datos': {},
      };

      for (var entry in _productosEscaneadosPorOrden.entries) {
        final orderId = entry.key.toString();
        final productos = entry.value;
        
        datosExport['datos'][orderId] = {
          'cantidadProductos': productos.length,
          'productos': productos.map((p) => _entryEntityToJson(p)).toList(),
        };
      }

      return jsonEncode(datosExport);
    } catch (e) {
      print('❌ Error al exportar datos: $e');
      return '';
    }
  }

  // Método para importar datos (para restaurar backup)
  Future<bool> importarDatosEscaneados(String jsonData) async {
    try {
      final Map<String, dynamic> datosImport = jsonDecode(jsonData);
      final Map<String, dynamic> datos = datosImport['datos'] ?? {};

      _productosEscaneadosPorOrden.clear();

      for (var entry in datos.entries) {
        final orderId = int.tryParse(entry.key);
        if (orderId != null) {
          final datosOrden = entry.value;
          final productosJson = datosOrden['productos'] as List<dynamic>;
          final productos = productosJson
              .map((json) => _entryEntityFromJson(json))
              .toList();
          
          _productosEscaneadosPorOrden[orderId] = productos;
        }
      }

      _productosEscaneadosPorOrden.refresh();
      await _guardarProductosEscaneados();

      print('✅ Datos importados exitosamente');
      return true;
    } catch (e) {
      print('❌ Error al importar datos: $e');
      return false;
    }
  }

  // Método para validar integridad de los datos
  Future<Map<String, dynamic>> validarIntegridadDatos() async {
    final resultado = <String, dynamic>{
      'esValido': true,
      'errores': <String>[],
      'advertencias': <String>[],
      'estadisticas': {},
    };

    try {
      int productosCorruptos = 0;
      int ordenesVacias = 0;

      for (var entry in _productosEscaneadosPorOrden.entries) {
        final orderId = entry.key;
        final productos = entry.value;

        if (productos.isEmpty) {
          ordenesVacias++;
          resultado['advertencias'].add('Orden $orderId no tiene productos escaneados');
          continue;
        }

        for (var producto in productos) {
          // Validar campos críticos
          if (producto.id == 0 || 
              producto.idProducto == 0 || 
              producto.producto?.codigo.isEmpty == true) {
            productosCorruptos++;
            resultado['errores'].add('Producto corrupto en orden $orderId: ID=${producto.id}');
            resultado['esValido'] = false;
          }

          // Validar piezas por pallet
          final piezas = int.tryParse(producto.piezasPorPallet);
          if (piezas == null || piezas < 0) {
            resultado['advertencias'].add('Valor inválido de piezas por pallet en orden $orderId: ${producto.piezasPorPallet}');
          }
        }
      }

      resultado['estadisticas'] = {
        'productosCorruptos': productosCorruptos,
        'ordenesVacias': ordenesVacias,
        'totalOrdenes': _productosEscaneadosPorOrden.length,
      };

    } catch (e) {
      resultado['esValido'] = false;
      resultado['errores'].add('Error durante la validación: $e');
    }

    return resultado;
  }

  // JSON Serialization Methods
  Map<String, dynamic> _entryEntityToJson(EntryEntity entry) {
    return {
      'id': entry.id,
      'id_entrada': entry.idEntrada,
      'id_producto': entry.idProducto,
      'maquina': entry.maquina,
      'ancho_ala': entry.anchoAla,
      'longitud': entry.longitud,
      'calibre': entry.calibre,
      'piezas_por_pallet': entry.piezasPorPallet,
      'camas_por_tarima': entry.camasPorTarima,
      'bultos_por_cama': entry.bultosPorCama,
      'piezas_por_bulto': entry.piezasPorBulto,
      'puntos': entry.puntos,
      'orden_compra': entry.ordenCompra,
      'observaciones': entry.observaciones,
      'tipo': {
        'id': entry.tipo?.id ?? 0,
        'tipo': entry.tipo?.tipo ?? '',
      },
      'producto': {
        'id': entry.producto?.id ?? 0,
        'nombre': entry.producto?.nombre ?? '',
        'codigo': entry.producto?.codigo ?? '',
      },
    };
  }

  EntryEntity _entryEntityFromJson(Map<String, dynamic> json) {
    return EntryEntity(
      id: json['id'] ?? 0,
      idEntrada: json['id_entrada'] ?? 0,
      idProducto: json['id_producto'] ?? 0,
      maquina: json['maquina'] ?? 0,
      anchoAla: json['ancho_ala'] ?? '',
      longitud: json['longitud'] ?? '',
      calibre: json['calibre'] ?? '',
      piezasPorPallet: json['piezas_por_pallet'] ?? '',    
      camasPorTarima: json['camas_por_tarima'] ?? '',     
      bultosPorCama: json['bultos_por_cama'] ?? '',        
      piezasPorBulto: json['piezas_por_bulto'] ?? '',    
      puntos: json['puntos'] ?? '',
      ordenCompra: json['orden_compra'] ?? '',            
      observaciones: json['observaciones'] ?? '',
      tipo: json['tipo'] != null && json['tipo'] is Map<String, dynamic>
          ? TipoEntity(
              id: json['tipo']['id'] ?? 0,
              tipo: json['tipo']['tipo'] ?? '',
            )
          : TipoEntity(id: 0, tipo: 'Desconocido'),
      producto: json['producto'] != null && json['producto'] is Map<String, dynamic>
          ? ProductEntity(
              id: json['producto']['id'] ?? 0,
              nombre: json['producto']['nombre'] ?? '',
              codigo: json['producto']['codigo'] ?? '',
            )
          : ProductEntity(id: 0, nombre: '', codigo: ''), 
      logs: [],
    );
  }
}