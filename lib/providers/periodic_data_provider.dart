import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/providers/monitoring_provider.dart';
import 'package:diabetes_fog_app/providers/auth_provider.dart';
import 'package:diabetes_fog_app/services/api_service.dart';
import 'package:diabetes_fog_app/models/monitoring_state.dart';

// Provider لخدمة API
final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});

// Provider لإدارة الإرسال الدوري للبيانات
final periodicDataProvider = StateNotifierProvider<PeriodicDataNotifier, bool>((ref) {
  return PeriodicDataNotifier(ref);
});

class PeriodicDataNotifier extends StateNotifier<bool> {
  final Ref _ref;
  Timer? _periodicTimer;

  PeriodicDataNotifier(this._ref) : super(false);

  // بدء الإرسال الدوري (كل 15 دقيقة أثناء الاستقرار)
  void startPeriodicSending() {
    if (state) {
      // الإرسال الدوري يعمل بالفعل
      return;
    }

    state = true;
    _periodicTimer?.cancel();
    
    // إرسال البيانات كل 15 دقيقة (900 ثانية)
    _periodicTimer = Timer.periodic(const Duration(minutes: 15), (timer) {
      _sendPeriodicDataIfStable();
    });
  }

  // إيقاف الإرسال الدوري
  void stopPeriodicSending() {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    state = false;
  }

  // إرسال البيانات بشكل دوري فقط أثناء الاستقرار
  Future<void> _sendPeriodicDataIfStable() async {
    try {
      // التحقق من أن الحالة الحالية هي stable
      final currentState = _ref.read(currentStateProvider);
      if (currentState != MonitoringState.stable) {
        // لا نرسل البيانات الدورية إلا أثناء الاستقرار
        return;
      }

      // الحصول على بيانات BGL الحالية
      final currentBGL = _ref.read(currentBGLProvider);
      if (currentBGL == null) {
        // لا توجد بيانات BGL حالياً
        return;
      }

      // الحصول على deviceId من authProvider
      final authState = _ref.read(authProvider);
      final deviceId = authState.deviceId;
      if (deviceId == null || deviceId.isEmpty) {
        print('Device ID is not available - user not logged in');
        return;
      }

      // الحصول على مستوى بطارية Fog (يمكن تحسينه لاحقاً باستخدام battery_plus)
      // في الوقت الحالي، نستخدم قيمة افتراضية أو محاكاة
      double batteryLevelFog = 100.0; // يمكن استبدالها بقيمة حقيقية من الجهاز

      // الحصول على ApiService من provider
      final apiService = _ref.read(apiServiceProvider);

      // إرسال البيانات
      await apiService.sendPeriodicDataLog(
        deviceId: deviceId,
        bglData: currentBGL,
        fogState: currentState,
        batteryLevelFog: batteryLevelFog,
      );
    } catch (e) {
      print('Error in periodic data sending: $e');
    }
  }

  @override
  void dispose() {
    _periodicTimer?.cancel();
    super.dispose();
  }
}

