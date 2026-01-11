import 'package:diabetes_fog_app/services/geolocation_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:diabetes_fog_app/models/settings_model.dart';
import 'package:diabetes_fog_app/models/watcher_model.dart';
import 'package:diabetes_fog_app/services/database_service.dart';
import 'package:diabetes_fog_app/services/api_service.dart';
import 'package:diabetes_fog_app/models/monitoring_state.dart';

class EmergencyService {
  // دمج خدمات الموقع هنا (لتنفيذ استراتيجية توفير الطاقة للموقع)
  final GeolocationService _geoLocationService = GeolocationService();
  final DatabaseService _databaseService = DatabaseService();
  final ApiService _apiService = ApiService();

  // ميثود للاتصال الآلي في الحالة الحرجة القصوى
  Future<void> triggerEmergencyCallAndSMS(double bgl) async {
    try {
      final locationData = await _geoLocationService.getHighAccuracyLocation();
      final settings = await _databaseService.getSettings();
      final deviceId = settings?.deviceID ?? 'UNKNOWN';
      
      // 1. الحصول على رقم الطوارئ من الإعدادات
      String? smsSentTo;
      bool callAttempted = false;
      
      if (settings?.emergencyNumber != null && settings!.emergencyNumber!.isNotEmpty) {
        // إجراء الاتصال الآلي (باستخدام url_launcher)
        final phoneUrl = Uri.parse('tel:${settings.emergencyNumber!}');
        if (await canLaunchUrl(phoneUrl)) {
          await launchUrl(phoneUrl);
          callAttempted = true;
        }
      }

      // 2. إرسال رسالة SMS مع رابط الموقع الجغرافي
      final locationUrl = 'https://www.google.com/maps?q=${locationData['latitude']},${locationData['longitude']}';
      final message = '🚨 حالة طوارئ حرجة! مستوى الجلوكوز: ${bgl.toStringAsFixed(1)} mg/dL\nالموقع: $locationUrl';
      
      // إرسال الرسائل للمراقبين وجمع أرقامهم
      final watchers = await _databaseService.getAllWatchers();
      final List<String> sentToNumbers = [];
      for (var watcher in watchers) {
        await _sendSMSMessage(watcher.phoneNumber, message);
        sentToNumbers.add(watcher.phoneNumber);
      }
      if (sentToNumbers.isNotEmpty) {
        smsSentTo = sentToNumbers.join(', ');
      }

      // 3. محاولة الحصول على عنوان جغرافي (Geocode)
      String addressGeocode = 'Unknown';
      try {
        // يمكن إضافة خدمة Geocoding هنا لاحقاً
        addressGeocode = '${locationData['latitude']}, ${locationData['longitude']}';
      } catch (e) {
        print('Error getting geocode: $e');
      }

      // 4. إرسال البيانات إلى API للحالات الحرجة
      final interventionDetails = {
        'sms_sent_to': smsSentTo ?? 'N/A',
        'call_attempted': callAttempted,
        'location_accuracy': 'HIGH_GPS',
        'address_geocode': addressGeocode,
      };

      await _apiService.sendCriticalEvent(
        deviceId: deviceId,
        bglTrigger: bgl,
        fogStateFinal: MonitoringState.criticalEmergency,
        interventionType: 'EMERGENCY_CALL',
        interventionDetails: interventionDetails,
      );

      print('Critical Call Triggered! BGL: $bgl, Location: ${locationData['latitude']}, ${locationData['longitude']}');
    } catch (e) {
      print('Error in triggerEmergencyCallAndSMS: $e');
    }
  }

  // ميثود لإرسال رسالة SMS للمراقبين في حالة الخطر الحاد
  Future<void> sendAcuteRiskSMS(double bgl) async {
    try {
      final locationData = _geoLocationService.getLastKnownNetworkLocation();
      final locationUrl = 'https://www.google.com/maps?q=${locationData['latitude']},${locationData['longitude']}';
      final message = '⚠️ خطر حاد! مستوى الجلوكوز: ${bgl.toStringAsFixed(1)} mg/dL\nالموقع: $locationUrl';

      // إرسال الرسائل للمراقبين
      final watchers = await _databaseService.getAllWatchers();
      for (var watcher in watchers) {
        await _sendSMSMessage(watcher.phoneNumber, message);
      }

      print('Acute Risk SMS Sent. BGL: $bgl, Location: ${locationData['latitude']}, ${locationData['longitude']}');
    } catch (e) {
      print('Error in sendAcuteRiskSMS: $e');
    }
  }

  // ميثود لإطلاق إشعار محلي في حالة الإنذار المسبق
  void sendPreAlertNotification(double bgl) {
    // 1. إطلاق إشعار محلي داخل تطبيق Flutter
    // سيتم تنفيذ هذا باستخدام flutter_local_notifications في المستقبل
    print('Pre-Alert Notification. BGL: $bgl');
  }

  // ميثود مساعد لإرسال رسالة SMS
  Future<void> _sendSMSMessage(String phoneNumber, String message) async {
    try {
      // تنظيف رقم الهاتف (إزالة المسافات والرموز، لكن نحتفظ بـ + في البداية)
      String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
      // إذا لم يبدأ بـ +، أضفه (افتراضي +963 الجمهورية العربية السورية)
      if (!cleanPhone.startsWith('+')) {
        // يمكن تعديل هذا حسب البلد الافتراضي
        cleanPhone = '+$cleanPhone';
      }
      
      // استخدام مخطط SMS URI لإرسال الرسالة
      final smsUrl = Uri.parse('sms:$cleanPhone?body=${Uri.encodeComponent(message)}');
      
      if (await canLaunchUrl(smsUrl)) {
        await launchUrl(smsUrl, mode: LaunchMode.externalApplication);
      } else {
        print('Cannot launch SMS: $smsUrl');
      }
    } catch (e) {
      print('Error sending SMS message: $e');
    }
  }

  // ميثود لاختبار الاتصال الآلي
  Future<void> testEmergencyCall(String emergencyNumber) async {
    try {
      if (emergencyNumber.isNotEmpty) {
        final phoneUrl = Uri.parse('tel:$emergencyNumber');
        if (await canLaunchUrl(phoneUrl)) {
          await launchUrl(phoneUrl);
        } else {
          throw Exception('Cannot launch phone call');
        }
      }
    } catch (e) {
      print('Error in testEmergencyCall: $e');
      rethrow;
    }
  }
}

