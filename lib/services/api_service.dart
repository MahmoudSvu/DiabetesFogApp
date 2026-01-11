import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:diabetes_fog_app/models/bgl_data_model.dart';
import 'package:diabetes_fog_app/models/monitoring_state.dart';
import 'package:diabetes_fog_app/services/database_service.dart';
import 'package:diabetes_fog_app/services/geolocation_service.dart';

class ApiService {
  final DatabaseService _databaseService = DatabaseService();
  final GeolocationService _geolocationService = GeolocationService();

  // الحصول على عنوان API الأساسي من الإعدادات
  Future<String?> _getApiBaseUrl() async {
    final settings = await _databaseService.getSettings();
    return settings?.apiBaseUrl;
  }

  // إرسال البيانات العادية بشكل دوري (كل 15 دقيقة أثناء الاستقرار)
  Future<bool> sendPeriodicDataLog({
    required String deviceId,
    required BGLDataModel bglData,
    required MonitoringState fogState,
    required double batteryLevelFog,
  }) async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
        print('API Base URL is not configured');
        return false;
      }

      // الحصول على الموقع
      final location = _geolocationService.getLastKnownNetworkLocation();
      
      // تحويل timestamp من milliseconds إلى ISO 8601 UTC
      final timestampUtc = DateTime.fromMillisecondsSinceEpoch(bglData.timestamp, isUtc: true)
          .toIso8601String();

      // تحويل MonitoringState إلى رقم (1=stable, 2=preAlert, 3=acuteRisk, 4=criticalEmergency)
      int fogStateValue = _monitoringStateToInt(fogState);

      // بناء البيانات المرسلة
      final payload = {
        'device_id': deviceId,
        'timestamp_utc': timestampUtc,
        'bgl_reading': bglData.bgl,
        'bgl_trend': bglData.trend,
        'fog_state': fogStateValue,
        'battery_level_edge': bglData.battery,
        'battery_level_fog': batteryLevelFog,
        'location_lat': location['latitude'],
        'location_long': location['longitude'],
        'interval_sent': 900, // 15 دقيقة = 900 ثانية
      };

      // إرسال الطلب
      final url = Uri.parse('$apiBaseUrl/api/v1/data/log');
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
  }) async {
    try {
      final apiBaseUrl = await _getApiBaseUrl();
      if (apiBaseUrl == null || apiBaseUrl.isEmpty) {
        print('API Base URL is not configured');
        return false;
      }

      // تحويل timestamp إلى ISO 8601 UTC
      final timestampEvent = DateTime.now().toUtc().toIso8601String();

      // تحويل MonitoringState إلى رقم
      int fogStateFinalValue = _monitoringStateToInt(fogStateFinal);

      // بناء البيانات المرسلة
      final payload = {
        'device_id': deviceId,
        'timestamp_event': timestampEvent,
        'bgl_trigger': bglTrigger,
        'fog_state_final': fogStateFinalValue,
        'intervention_type': interventionType,
        'intervention_details': interventionDetails,
      };

      // إرسال الطلب
      final url = Uri.parse('$apiBaseUrl/api/v1/events/critical');
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
}

