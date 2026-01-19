import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

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

  // الحصول على العنوان من الإحداثيات (Reverse Geocoding)
  Future<String> getAddressFromCoordinates(double latitude, double longitude) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(latitude, longitude);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        // بناء العنوان من المكونات المتاحة
        final addressParts = <String>[];
        
        if (place.street != null && place.street!.isNotEmpty) {
          addressParts.add(place.street!);
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          addressParts.add(place.subLocality!);
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          addressParts.add(place.locality!);
        }
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) {
          addressParts.add(place.administrativeArea!);
        }
        if (place.country != null && place.country!.isNotEmpty) {
          addressParts.add(place.country!);
        }
        
        if (addressParts.isNotEmpty) {
          return addressParts.join(', ');
        } else {
          return '$latitude, $longitude'; // إذا لم يتم العثور على عنوان، نعيد الإحداثيات
        }
      } else {
        return '$latitude, $longitude'; // إذا لم يتم العثور على عنوان، نعيد الإحداثيات
      }
    } catch (e) {
      print('Error getting address from coordinates: $e');
      return '$latitude, $longitude'; // في حالة الخطأ، نعيد الإحداثيات
    }
  }

  // الحصول على الموقع الحالي مع العنوان
  Future<Map<String, dynamic>> getCurrentLocationWithAddress() async {
    try {
      // الحصول على الموقع الحالي
      final location = await getHighAccuracyLocation();
      final lat = location['latitude']!;
      final lon = location['longitude']!;
      
      // الحصول على العنوان
      final address = await getAddressFromCoordinates(lat, lon);
      
      return {
        'latitude': lat,
        'longitude': lon,
        'address': address,
      };
    } catch (e) {
      print('Error getting current location with address: $e');
      return {
        'latitude': 0.0,
        'longitude': 0.0,
        'address': 'Unknown Location',
      };
    }
  }

  // الحصول على آخر موقع معروف مع العنوان
  Future<Map<String, dynamic>> getLastKnownLocationWithAddress() async {
    try {
      final location = getLastKnownNetworkLocation();
      final lat = location['latitude']!;
      final lon = location['longitude']!;
      
      // إذا كانت الإحداثيات صفر، نحاول الحصول على موقع جديد
      if (lat == 0.0 && lon == 0.0) {
        return await getCurrentLocationWithAddress();
      }
      
      // الحصول على العنوان
      final address = await getAddressFromCoordinates(lat, lon);
      
      return {
        'latitude': lat,
        'longitude': lon,
        'address': address,
      };
    } catch (e) {
      print('Error getting last known location with address: $e');
      return {
        'latitude': 0.0,
        'longitude': 0.0,
        'address': 'Unknown Location',
      };
    }
  }
}

