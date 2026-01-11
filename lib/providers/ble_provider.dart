import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:diabetes_fog_app/services/ble_service.dart';
import 'package:diabetes_fog_app/models/bgl_data_model.dart';
import 'package:diabetes_fog_app/providers/monitoring_provider.dart';
import 'package:diabetes_fog_app/services/database_service.dart';
import 'package:diabetes_fog_app/models/event_log_model.dart';
import 'package:diabetes_fog_app/models/monitoring_state.dart';
import 'package:diabetes_fog_app/providers/periodic_data_provider.dart';
import 'package:diabetes_fog_app/providers/monitoring_provider.dart';

// Provider لحالة اتصال BLE
final bleConnectionProvider = StateNotifierProvider<BleConnectionNotifier, BleConnectionState>((ref) {
  return BleConnectionNotifier(ref);
});

// Provider للأجهزة المكتشفة
final scannedDevicesProvider = StateProvider<List<ScanResult>>((ref) => []);

enum BleConnectionState {
  disconnected,
  scanning,
  connecting,
  connected,
  error,
}

class BleConnectionNotifier extends StateNotifier<BleConnectionState> {
  final Ref _ref;
  BleService? _bleService;
  final DatabaseService _databaseService = DatabaseService();

  BleConnectionNotifier(this._ref) : super(BleConnectionState.disconnected) {
    _initializeBle();
  }

  Future<void> _initializeBle() async {
    _bleService = _ref.read(bleServiceProvider);
    
    // إعداد callback لاستقبال البيانات
    _bleService!.onDataReceived = (BGLDataModel data) {
      _handleIncomingData(data);
    };
  }

  // بدء البحث عن الأجهزة
  Future<void> startScan() async {
    try {
      // التحقق من تفعيل Bluetooth
      final isEnabled = await _bleService!.isBluetoothEnabled();
      if (!isEnabled) {
        await _bleService!.turnOnBluetooth();
        // انتظار قليل لتفعيل Bluetooth
        await Future.delayed(const Duration(seconds: 2));
      }

      state = BleConnectionState.scanning;
      
      // مسح الأجهزة السابقة
      _ref.read(scannedDevicesProvider.notifier).state = [];
      
      // بدء البحث
      _bleService!.scanForDevices(timeout: const Duration(seconds: 10)).listen((results) {
        _ref.read(scannedDevicesProvider.notifier).state = results;
      });
    } catch (e) {
      print('BLE scan error: $e');
      state = BleConnectionState.error;
    }
  }

  // إيقاف البحث
  Future<void> stopScan() async {
    await _bleService?.stopScan();
    if (state == BleConnectionState.scanning) {
      state = BleConnectionState.disconnected;
    }
  }

  // الاتصال بجهاز
  Future<void> connect(BluetoothDevice device) async {
    try {
      state = BleConnectionState.connecting;
      
      // إيقاف البحث إذا كان يعمل
      await stopScan();

      final connected = await _bleService!.connect(device);

      if (connected) {
        state = BleConnectionState.connected;
        // بدء الإرسال الدوري للبيانات عند الاتصال
        _ref.read(periodicDataProvider.notifier).startPeriodicSending();
      } else {
        state = BleConnectionState.error;
      }
    } catch (e) {
      print('BLE connection error: $e');
      state = BleConnectionState.error;
    }
  }

  // قطع الاتصال
  void disconnect() {
    _bleService?.disconnect();
    state = BleConnectionState.disconnected;
    // إيقاف الإرسال الدوري عند قطع الاتصال
    _ref.read(periodicDataProvider.notifier).stopPeriodicSending();
  }

  // إرسال أمر التحكم
  Future<void> sendCommand(Map<String, dynamic> command) async {
    if (state == BleConnectionState.connected) {
      await _bleService?.sendCommand(command);
    }
  }

  void _handleIncomingData(BGLDataModel data) {
    // تحديث بيانات BGL الحالية
    _ref.read(currentBGLProvider.notifier).state = data;
    
    // تحليل البيانات عبر FogOrchestrator
    final orchestrator = _ref.read(fogOrchestratorProvider);
    orchestrator.analyzeBGLData(data).then((_) {
      // تحديث حالة النظام
      final newState = orchestrator.currentState;
      final previousState = _ref.read(currentStateProvider);
      _ref.read(currentStateProvider.notifier).state = newState;
      
      // التحكم في الإرسال الدوري بناءً على الحالة
      if (newState == MonitoringState.stable && previousState != MonitoringState.stable) {
        // إذا تحولت الحالة إلى stable، ابدأ الإرسال الدوري
        _ref.read(periodicDataProvider.notifier).startPeriodicSending();
      } else if (newState != MonitoringState.stable && previousState == MonitoringState.stable) {
        // إذا خرجت من حالة stable، أوقف الإرسال الدوري
        _ref.read(periodicDataProvider.notifier).stopPeriodicSending();
      }
      
      // إضافة حدث إلى السجل
      final event = EventLogModel(
        timestamp: DateTime.now().millisecondsSinceEpoch,
        bgl: data.bgl,
        state: newState,
        eventType: 'reading',
        message: 'BGL: ${data.bgl.toStringAsFixed(1)} mg/dL',
      );
      _ref.read(eventLogProvider.notifier).addEvent(event);
    });
  }

  bool get isConnected => _bleService?.isConnected ?? false;
}

