import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart';

/// خدمة لإدارة صلاحيات الموقع
/// متوافقة مع Android 10+ (API 29+)
class PermissionService {
  /// طلب صلاحيات الموقع مع معالجة مناسبة
  /// يُستخدم عند بدء التطبيق لأول مرة
  static Future<LocationPermissionStatus> requestLocationPermission() async {
    try {
      // 1. التحقق من تفعيل خدمات الموقع
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      // 2. التحقق من الصلاحيات الحالية
      LocationPermission permission = await Geolocator.checkPermission();
      
      // 3. إذا كانت الصلاحيات مرفوضة، اطلبها
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          return LocationPermissionStatus.denied;
        }
      }

      // 4. إذا كانت الصلاحيات مرفوضة نهائياً
      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      }

      // 5. الصلاحيات مُعطاة
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        return LocationPermissionStatus.granted;
      }

      return LocationPermissionStatus.denied;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error requesting location permission: $e');
      }
      return LocationPermissionStatus.error;
    }
  }

  /// فتح إعدادات التطبيق لإعطاء الصلاحيات يدوياً
  static Future<void> openAppSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// فتح إعدادات الموقع في النظام
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// التحقق من حالة الصلاحيات الحالية
  static Future<LocationPermissionStatus> checkLocationPermission() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        return LocationPermissionStatus.serviceDisabled;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        return LocationPermissionStatus.denied;
      }
      
      if (permission == LocationPermission.deniedForever) {
        return LocationPermissionStatus.deniedForever;
      }
      
      if (permission == LocationPermission.whileInUse || 
          permission == LocationPermission.always) {
        return LocationPermissionStatus.granted;
      }

      return LocationPermissionStatus.denied;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error checking location permission: $e');
      }
      return LocationPermissionStatus.error;
    }
  }
}

/// حالات صلاحيات الموقع
enum LocationPermissionStatus {
  granted,              // الصلاحيات مُعطاة
  denied,               // الصلاحيات مرفوضة
  deniedForever,        // الصلاحيات مرفوضة نهائياً
  serviceDisabled,     // خدمات الموقع معطلة
  error,                // خطأ في الطلب
}

