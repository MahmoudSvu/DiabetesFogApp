import 'dart:convert';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:diabetes_fog_app/models/bgl_data_model.dart';

// UUIDs للخدمات والخصائص BLE (يمكن تخصيصها حسب ESP32)
class BleUuids {
  // Service UUID للبيانات
  static const String dataServiceUuid = '0000180f-0000-1000-8000-00805f9b34fb';
  
  // Characteristic UUID لاستقبال البيانات من ESP32
  static const String dataCharacteristicUuid = '00002a19-0000-1000-8000-00805f9b34fb';
  
  // Characteristic UUID لإرسال الأوامر إلى ESP32
  static const String commandCharacteristicUuid = '00002a1c-0000-1000-8000-00805f9b34fb';
}

class BleService {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _dataCharacteristic;
  BluetoothCharacteristic? _commandCharacteristic;
  Function(BGLDataModel)? onDataReceived;

  // البحث عن الأجهزة BLE
  Stream<List<ScanResult>> scanForDevices({Duration timeout = const Duration(seconds: 10)}) {
    FlutterBluePlus.startScan(timeout: timeout);
    return FlutterBluePlus.scanResults;
  }

  // إيقاف البحث
  Future<void> stopScan() async {
    await FlutterBluePlus.stopScan();
  }

  // الاتصال بجهاز ESP32
  Future<bool> connect(BluetoothDevice device) async {
    try {
      _connectedDevice = device;
      
      // الاتصال بالجهاز
      await device.connect(
        timeout: const Duration(seconds: 15),
        autoConnect: false,
      );

      // اكتشاف الخدمات
      List<BluetoothService> services = await device.discoverServices();

      // البحث عن خدمة البيانات
      BluetoothService? dataService;
      for (var service in services) {
        if (service.uuid.toString().toLowerCase() == BleUuids.dataServiceUuid.toLowerCase() ||
            service.uuid.toString().toLowerCase().contains('180f')) {
          dataService = service;
          break;
        }
      }

      if (dataService == null) {
        // إذا لم نجد الخدمة المحددة، نستخدم أول خدمة متاحة
        if (services.isNotEmpty) {
          dataService = services.first;
        } else {
          print('No services found');
          return false;
        }
      }

      // البحث عن الخصائص
      for (var characteristic in dataService.characteristics) {
        // Characteristic لاستقبال البيانات
        if (characteristic.properties.read || characteristic.properties.notify) {
          _dataCharacteristic = characteristic;
          
          // تفعيل الإشعارات إذا كانت متاحة
          if (characteristic.properties.notify) {
            await characteristic.setNotifyValue(true);
            characteristic.onValueReceived.listen((value) {
              _handleIncomingData(value);
            });
          }
        }
        
        // Characteristic لإرسال الأوامر
        if (characteristic.properties.write || characteristic.properties.writeWithoutResponse) {
          _commandCharacteristic = characteristic;
        }
      }

      // إذا لم نجد الخصائص المحددة، نستخدم أول خصائص متاحة
      if (_dataCharacteristic == null && dataService.characteristics.isNotEmpty) {
        _dataCharacteristic = dataService.characteristics.first;
        if (_dataCharacteristic!.properties.notify) {
          await _dataCharacteristic!.setNotifyValue(true);
          _dataCharacteristic!.onValueReceived.listen((value) {
            _handleIncomingData(value);
          });
        }
      }

      if (_commandCharacteristic == null && dataService.characteristics.length > 1) {
        _commandCharacteristic = dataService.characteristics.length > 1 
            ? dataService.characteristics[1] 
            : dataService.characteristics.first;
      }

      print('BLE device connected successfully');
      return true;
    } catch (e) {
      print('BLE connection error: $e');
      return false;
    }
  }

  // معالجة البيانات الواردة
  void _handleIncomingData(List<int> value) {
    try {
      // تحويل البيانات من bytes إلى string
      String jsonString = utf8.decode(value);
      
      // تحويل JSON string إلى Map
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      
      // تحويل إلى BGLDataModel
      final bglData = BGLDataModel.fromJson(data);
      
      // استدعاء callback
      onDataReceived?.call(bglData);
    } catch (e) {
      print('Error parsing BLE data: $e');
      // محاولة قراءة البيانات مباشرة إذا فشل التحويل
      try {
        if (value.length >= 8) {
          // تنسيق بسيط: [deviceID, timestamp, bgl, trend, battery, status, interruptFlag]
          // هذا مثال بسيط - يجب تخصيصه حسب تنسيق ESP32
          print('Received raw data: $value');
        }
      } catch (e2) {
        print('Error handling raw data: $e2');
      }
    }
  }

  // إرسال أمر التحكم إلى ESP32
  Future<bool> sendCommand(Map<String, dynamic> command) async {
    try {
      if (_commandCharacteristic == null) {
        print('Command characteristic not available');
        return false;
      }

      // تحويل الأمر إلى JSON
      String jsonString = jsonEncode(command);
      List<int> bytes = utf8.encode(jsonString);

      // إرسال البيانات
      if (_commandCharacteristic!.properties.write) {
        await _commandCharacteristic!.write(bytes, withoutResponse: false);
      } else if (_commandCharacteristic!.properties.writeWithoutResponse) {
        await _commandCharacteristic!.write(bytes, withoutResponse: true);
      } else {
        print('Characteristic does not support write');
        return false;
      }

      print('Command sent successfully: $command');
      return true;
    } catch (e) {
      print('Error sending command: $e');
      return false;
    }
  }

  // قراءة البيانات يدوياً (إذا لم تكن الإشعارات متاحة)
  Future<BGLDataModel?> readData() async {
    try {
      if (_dataCharacteristic == null) {
        print('Data characteristic not available');
        return null;
      }

      if (!_dataCharacteristic!.properties.read) {
        print('Characteristic does not support read');
        return null;
      }

      List<int> value = await _dataCharacteristic!.read();
      String jsonString = utf8.decode(value);
      final data = jsonDecode(jsonString) as Map<String, dynamic>;
      return BGLDataModel.fromJson(data);
    } catch (e) {
      print('Error reading data: $e');
      return null;
    }
  }

  // قطع الاتصال
  Future<void> disconnect() async {
    try {
      if (_connectedDevice != null) {
        await _connectedDevice!.disconnect();
        _connectedDevice = null;
        _dataCharacteristic = null;
        _commandCharacteristic = null;
        print('BLE device disconnected');
      }
    } catch (e) {
      print('Error disconnecting: $e');
    }
  }

  // التحقق من حالة الاتصال
  bool get isConnected {
    return _connectedDevice?.isConnected ?? false;
  }

  // الحصول على الجهاز المتصل
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // التحقق من تفعيل Bluetooth
  Future<bool> isBluetoothEnabled() async {
    return await FlutterBluePlus.isSupported.then((supported) {
      if (!supported) return false;
      return FlutterBluePlus.adapterState.first.then((state) {
        return state == BluetoothAdapterState.on;
      });
    });
  }

  // تفعيل Bluetooth
  Future<void> turnOnBluetooth() async {
    if (await FlutterBluePlus.isSupported) {
      await FlutterBluePlus.turnOn();
    }
  }
}

