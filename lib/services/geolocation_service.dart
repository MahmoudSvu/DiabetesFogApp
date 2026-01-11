import 'package:geolocator/geolocator.dart';

// كلاس لخدمة الموقع - سيتم تطويره بناءً على استراتيجية توفير الطاقة
class GeolocationService {
  Position? _lastKnownPosition;
  Position? _lastNetworkPosition;

  // ميثود للحصول على موقع عالي الدقة (GPS) - يُستخدم في الحالات الحرجة
  Future<Map<String, double>> getHighAccuracyLocation() async {
    try {
      // التحقق من الصلاحيات
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      // الحصول على الموقع بدقة عالية
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      _lastKnownPosition = position;
      return {
        'latitude': position.latitude,
        'longitude': position.longitude,
      };
    } catch (e) {
      // في حالة الفشل، إرجاع آخر موقع معروف
      if (_lastKnownPosition != null) {
        return {
          'latitude': _lastKnownPosition!.latitude,
          'longitude': _lastKnownPosition!.longitude,
        };
      }
      // القيمة الافتراضية
      return {'latitude': 0.0, 'longitude': 0.0};
    }
  }

  // ميثود للحصول على آخر موقع معروف عبر الشبكة (توفير الطاقة)
  Map<String, double> getLastKnownNetworkLocation() {
    if (_lastNetworkPosition != null) {
      return {
        'latitude': _lastNetworkPosition!.latitude,
        'longitude': _lastNetworkPosition!.longitude,
      };
    }

    // محاولة الحصول على موقع تقريبي عبر الشبكة
    // في التطبيق الحقيقي، يمكن استخدام Network Location Provider
    if (_lastKnownPosition != null) {
      return {
        'latitude': _lastKnownPosition!.latitude,
        'longitude': _lastKnownPosition!.longitude,
      };
    }

    return {'latitude': 0.0, 'longitude': 0.0};
  }

  // تحديث آخر موقع معروف
  void updateLastKnownPosition(Position position) {
    _lastKnownPosition = position;
  }

  // تحديث آخر موقع شبكة
  void updateLastNetworkPosition(Position position) {
    _lastNetworkPosition = position;
  }
}

