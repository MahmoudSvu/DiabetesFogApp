import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:diabetes_fog_app/models/bgl_data_model.dart';
import 'package:diabetes_fog_app/models/monitoring_state.dart';
import 'package:diabetes_fog_app/services/database_service.dart';
import 'package:diabetes_fog_app/services/geolocation_service.dart';

class ApiService {
  final DatabaseService _databaseService = DatabaseService();
  final GeolocationService _geolocationService = GeolocationService();

  // عنوان API الأساسي
  static const String baseUrl = 'http://realestate26-001-site2.ltempurl.com';

  // تسجيل الدخول باستخدام كود المريض
  Future<String?> login(String patientCode) async {
    try {
      // تنظيف الكود من المسافات
      final cleanCode = patientCode.trim().toUpperCase();
      final url = Uri.parse('$baseUrl/api/Patient/MobileLogin?code=$cleanCode');
      
      print('Attempting to connect to: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 30), // زيادة المهلة إلى 30 ثانية
        onTimeout: () {
          throw Exception('Request timeout - الخادم لا يستجيب');
        },
      );

      if (response.statusCode == 200) {
        // API يعيد Guid مباشرة كـ string
        final deviceId = response.body.trim();
        
        // إزالة الاقتباسات إذا كانت موجودة
        final cleanDeviceId = deviceId.replaceAll('"', '').trim();
        
        if (cleanDeviceId.isNotEmpty && cleanDeviceId != 'null') {
          print('Login successful. Device ID: $cleanDeviceId');
          return cleanDeviceId;
        } else {
          print('Invalid device ID received: $deviceId');
          return null;
        }
      } else {
        print('Login failed: ${response.statusCode} - ${response.body}');
        return null;
      }
    } on SocketException catch (e) {
      print('Network error during login: $e');
      // إعادة المحاولة مرة واحدة
      try {
        print('Retrying login...');
        await Future.delayed(const Duration(seconds: 2));
        final retryUrl = Uri.parse('$baseUrl/api/Patient/MobileLogin?code=${patientCode.trim().toUpperCase()}');
        final retryResponse = await http.get(
          retryUrl,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ).timeout(const Duration(seconds: 30));
        
        if (retryResponse.statusCode == 200) {
          final deviceId = retryResponse.body.trim().replaceAll('"', '').trim();
          if (deviceId.isNotEmpty && deviceId != 'null') {
            print('Login successful on retry. Device ID: $deviceId');
            return deviceId;
          }
        }
      } catch (retryError) {
        print('Retry also failed: $retryError');
      }
      return null;
    } catch (e) {
      print('Error during login: $e');
      return null;
    }
  }

  // إرسال البيانات العادية بشكل دوري (كل 15 دقيقة أثناء الاستقرار)
  Future<bool> sendPeriodicDataLog({
    required String deviceId,
    required BGLDataModel bglData,
    required MonitoringState fogState,
    double? batteryLevelFog,
  }) async {
    try {
      // الحصول على الموقع مع العنوان
      final locationData = await _geolocationService.getLastKnownLocationWithAddress();
      
      // تحويل MonitoringState إلى رقم (1=stable, 2=preAlert, 3=acuteRisk, 4=criticalEmergency)
      int fogStateValue = _monitoringStateToInt(fogState);

      // حساب intervalSent بناءً على الحالة
      int intervalSent = _getIntervalForState(fogState);

      // استخدام العنوان في lastLocation، أو الإحداثيات إذا لم يتوفر العنوان
      String lastLocation = locationData['address'] ?? '${locationData['latitude']}, ${locationData['longitude']}';

      // استخدام قيمة البطارية الممررة أو القيمة الافتراضية
      final batteryLevel = batteryLevelFog ?? 100.0; // القيمة الافتراضية 100%

      // بناء البيانات المرسلة حسب API الجديد
      final payload = {
        'deviceId': deviceId,
        'bglreading': bglData.bgl,
        'bglTrend': bglData.trend,
        'fogState': fogStateValue,
        'intervalSent': intervalSent,
        'lat': locationData['latitude'],
        'long': locationData['longitude'],
        'lastLocation': lastLocation,
        'batteryLevelFog': batteryLevel, // إضافة مستوى البطارية
      };

      // إرسال الطلب
      final url = Uri.parse('$baseUrl/api/DataLog/Add');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Periodic data log sent successfully');
        return true;
      } else {
        print('Failed to send periodic data log: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending periodic data log: $e');
      return false;
    }
  }

  // إرسال الحالات الحرجة والتدخلات
  Future<bool> sendCriticalEvent({
    required String deviceId,
    required double bglTrigger,
    required MonitoringState fogStateFinal,
    required String interventionType,
    required Map<String, dynamic> interventionDetails,
    double? batteryLevelFog,
  }) async {
    try {
      // الحصول على الموقع الحالي الحقيقي مع العنوان (في الحالات الحرجة نحتاج موقع دقيق)
      final locationData = await _geolocationService.getCurrentLocationWithAddress();
      
      // تحويل MonitoringState إلى رقم
      int fogStateFinalValue = _monitoringStateToInt(fogStateFinal);

      // حساب intervalSent بناءً على الحالة
      int intervalSent = _getIntervalForState(fogStateFinal);

      // استخدام العنوان في lastLocation، أو الإحداثيات إذا لم يتوفر العنوان
      String lastLocation = locationData['address'] ?? '${locationData['latitude']}, ${locationData['longitude']}';

      // استخدام قيمة البطارية الممررة أو القيمة الافتراضية
      final batteryLevel = batteryLevelFog ?? 100.0; // القيمة الافتراضية 100%

      // بناء البيانات المرسلة حسب API الجديد
      final payload = {
        'deviceId': deviceId,
        'bglreading': bglTrigger,
        'bglTrend': 0, // يمكن تحديثه لاحقاً
        'fogState': fogStateFinalValue,
        'intervalSent': intervalSent,
        'lat': locationData['latitude'],
        'long': locationData['longitude'],
        'lastLocation': lastLocation,
        'batteryLevelFog': batteryLevel, // إضافة مستوى البطارية
      };

      // إرسال الطلب - استخدام نفس API لإرسال البيانات
      final url = Uri.parse('$baseUrl/api/DataLog/Add');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(payload),
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('Critical event sent successfully');
        return true;
      } else {
        print('Failed to send critical event: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error sending critical event: $e');
      return false;
    }
  }

  // تحويل MonitoringState إلى رقم
  int _monitoringStateToInt(MonitoringState state) {
    switch (state) {
      case MonitoringState.stable:
        return 1;
      case MonitoringState.preAlert:
        return 2;
      case MonitoringState.acuteRisk:
        return 3;
      case MonitoringState.criticalEmergency:
        return 4;
    }
  }

  // حساب intervalSent بناءً على الحالة (بالثواني)
  int _getIntervalForState(MonitoringState state) {
    switch (state) {
      case MonitoringState.stable:
        return 900; // 15 دقيقة = 900 ثانية
      case MonitoringState.preAlert:
        return 300; // 5 دقائق = 300 ثانية
      case MonitoringState.acuteRisk:
        return 60; // دقيقة واحدة = 60 ثانية
      case MonitoringState.criticalEmergency:
        return 30; // 30 ثانية
    }
  }
}

