import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/models/bgl_data_model.dart';
import 'package:diabetes_fog_app/models/monitoring_state.dart';
import 'package:diabetes_fog_app/providers/auth_provider.dart';
import 'package:diabetes_fog_app/services/geolocation_service.dart';

// Provider لإدارة الإرسال التجريبي للبيانات
final testDataProvider = StateNotifierProvider<TestDataNotifier, TestDataState>((ref) {
  return TestDataNotifier(ref);
});

class TestDataState {
  final bool isRunning;
  final MonitoringState currentTestState;
  final int sentCount;
  final String? lastError;

  TestDataState({
    this.isRunning = false,
    this.currentTestState = MonitoringState.stable,
    this.sentCount = 0,
    this.lastError,
  });

  TestDataState copyWith({
    bool? isRunning,
    MonitoringState? currentTestState,
    int? sentCount,
    String? lastError,
  }) {
    return TestDataState(
      isRunning: isRunning ?? this.isRunning,
      currentTestState: currentTestState ?? this.currentTestState,
      sentCount: sentCount ?? this.sentCount,
      lastError: lastError ?? this.lastError,
    );
  }
}

class TestDataNotifier extends StateNotifier<TestDataState> {
  final Ref _ref;
  Timer? _testTimer;
  final GeolocationService _geolocationService = GeolocationService();
  
  // قيم ثابتة تجريبية لكل حالة
  final Map<MonitoringState, Map<String, dynamic>> _testValues = {
    MonitoringState.stable: {
      'bgl': 120.0,
      'trend': 0,
      'battery': 85.0,
      'status': 1,
      'interval': 900, // 15 دقيقة
    },
    MonitoringState.preAlert: {
      'bgl': 85.0, // أقل من الحد الأدنى الآمن
      'trend': -1,
      'battery': 75.0,
      'status': 2,
      'interval': 300, // 5 دقائق
    },
    MonitoringState.acuteRisk: {
      'bgl': 65.0, // في نطاق الخطر الحاد المنخفض
      'trend': -2,
      'battery': 60.0,
      'status': 3,
      'interval': 60, // دقيقة واحدة
    },
    MonitoringState.criticalEmergency: {
      'bgl': 45.0, // أقل من الحد الأدنى للخطر الحاد
      'trend': -2,
      'battery': 50.0,
      'status': 4,
      'interval': 30, // 30 ثانية
    },
  };

  int _currentStateIndex = 0;
  final List<MonitoringState> _states = [
    MonitoringState.stable,
    MonitoringState.preAlert,
    MonitoringState.acuteRisk,
    MonitoringState.criticalEmergency,
  ];

  TestDataNotifier(this._ref) : super(TestDataState());

  // بدء الإرسال التجريبي
  void startTestSending() {
    if (state.isRunning) {
      return;
    }

    state = state.copyWith(isRunning: true, sentCount: 0, lastError: null);
    
    // إرسال البيانات كل 20 ثانية (للتجربة)
    _testTimer = Timer.periodic(const Duration(seconds: 20), (timer) {
      _sendTestData();
    });
    
    // إرسال أول بيانات فوراً
    _sendTestData();
  }

  // إيقاف الإرسال التجريبي
  void stopTestSending() {
    _testTimer?.cancel();
    _testTimer = null;
    state = state.copyWith(isRunning: false);
  }

  // إرسال بيانات تجريبية
  Future<void> _sendTestData() async {
    try {
      // الحصول على deviceId من authProvider
      final authState = _ref.read(authProvider);
      final deviceId = authState.deviceId;
      
      if (deviceId == null || deviceId.isEmpty) {
        state = state.copyWith(
          lastError: 'Device ID غير متوفر. يرجى تسجيل الدخول أولاً.',
          isRunning: false,
        );
        stopTestSending();
        return;
      }

      // الحصول على الحالة الحالية
      final currentState = _states[_currentStateIndex];
      final testValues = _testValues[currentState]!;

      // إنشاء BGLDataModel تجريبي
      final testBGLData = BGLDataModel(
        deviceID: 'TEST_DEVICE',
        timestamp: DateTime.now().millisecondsSinceEpoch,
        bgl: testValues['bgl'] as double,
        trend: testValues['trend'] as int,
        battery: testValues['battery'] as double,
        status: testValues['status'] as int,
        interruptFlag: currentState == MonitoringState.criticalEmergency,
      );

      // الحصول على الموقع
      final location = _geolocationService.getLastKnownNetworkLocation();
      final batteryLevelFog = 90.0; // قيمة تجريبية لبطارية Fog

      // الحصول على ApiService من provider
      final apiService = _ref.read(apiServiceProvider);
      
      // إرسال البيانات
      final success = await apiService.sendPeriodicDataLog(
        deviceId: deviceId,
        bglData: testBGLData,
        fogState: currentState,
        batteryLevelFog: batteryLevelFog,
      );

      if (success) {
        // الانتقال إلى الحالة التالية في الحلقة
        _currentStateIndex = (_currentStateIndex + 1) % _states.length;
        final nextState = _states[_currentStateIndex];
        
        state = state.copyWith(
          sentCount: state.sentCount + 1,
          currentTestState: currentState,
          lastError: null,
        );

        // حساب intervalSent المتوقع بناءً على الحالة
        final expectedInterval = testValues['interval'] as int;
        print('Test data sent successfully: State=${currentState.displayName}, BGL=${testValues['bgl']}, IntervalSent=$expectedInterval, Count=${state.sentCount}');
      } else {
        state = state.copyWith(
          lastError: 'فشل إرسال البيانات. تحقق من الاتصال بالإنترنت.',
        );
      }
    } catch (e) {
      print('Error sending test data: $e');
      state = state.copyWith(
        lastError: 'خطأ في الإرسال: ${e.toString()}',
      );
    }
  }

  @override
  void dispose() {
    _testTimer?.cancel();
    super.dispose();
  }
}
