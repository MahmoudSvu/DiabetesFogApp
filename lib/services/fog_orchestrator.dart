import 'package:diabetes_fog_app/models/bgl_data_model.dart';
import 'package:diabetes_fog_app/models/monitoring_state.dart';
import 'package:diabetes_fog_app/services/emergency_service.dart';
import 'package:diabetes_fog_app/services/ble_service.dart';
import 'package:diabetes_fog_app/services/database_service.dart';

class FogOrchestrator {
  final EmergencyService _emergencyService; // حقن خدمة الطوارئ
  final BleService _bleService;
  final DatabaseService _databaseService = DatabaseService();
  
  MonitoringState _currentState = MonitoringState.stable;

  FogOrchestrator(this._emergencyService, this._bleService);

  MonitoringState get currentState => _currentState;

  // الخوارزمية التكيفية: تحدد الحالة وتتخذ الإجراء المناسب
  Future<void> analyzeBGLData(BGLDataModel data) async {
    // 1. تحديد الحالة الجديدة بناءً على الخوارزمية المنطقية (If-Else)
    MonitoringState newState = await _determineState(data);

    // 2. اتخاذ الإجراءات اللازمة
    _processStateActions(newState, data);

    // 3. تحديث وإرسال أمر التردد الجديد إلى الحافة
    _sendControlCommand(newState, data.deviceID);

    _currentState = newState; // تحديث الحالة الحالية للنظام
  }

  // ميثود لتطبيق منطق الخوارزمية بناءً على BGL و Trend
  Future<MonitoringState> _determineState(BGLDataModel data) async {
    final bgl = data.bgl;
    final trend = data.trend;
    
    // الحصول على الإعدادات من قاعدة البيانات
    final settings = await _databaseService.getSettings();
    
    // استخدام القيم الافتراضية إذا لم تكن الإعدادات موجودة
    final acuteRiskLowMin = settings?.acuteRiskLowMin ?? 54.0;
    final acuteRiskLowMax = settings?.acuteRiskLowMax ?? 70.0;
    final acuteRiskHighMin = settings?.acuteRiskHighMin ?? 250.0;
    final acuteRiskHighMax = settings?.acuteRiskHighMax ?? 300.0;
    final safetyRangeMin = settings?.safetyRangeMin ?? 90.0;
    final safetyRangeMax = settings?.safetyRangeMax ?? 180.0;

    // --- الشروط المنطقية (من الأشد خطورة إلى الأقل) ---

    // 4. الحرجية القُصوى (Critical Emergency)
    if (bgl < acuteRiskLowMin || 
        bgl > acuteRiskHighMax || 
        (bgl < acuteRiskLowMax && trend == -2) || 
        data.interruptFlag) {
      return MonitoringState.criticalEmergency;
    }

    // 3. الخطر الحاد (Acute Risk)
    if ((bgl >= acuteRiskLowMin && bgl < acuteRiskLowMax) || 
        (bgl > acuteRiskHighMin && bgl <= acuteRiskHighMax) || 
        (trend.abs() == 2)) {
      return MonitoringState.acuteRisk;
    }

    // 2. الإنذار المُسبق (Pre-Alert)
    if ((bgl >= acuteRiskLowMax && bgl < safetyRangeMin && trend == -1) || 
        (bgl > safetyRangeMax && bgl <= acuteRiskHighMin)) {
      return MonitoringState.preAlert;
    }

    // 1. الاستقرار (Stable) - الشرط الافتراضي
    return MonitoringState.stable;
  }

  // ميثود لتنفيذ الإجراءات (الإشعارات والاتصال)
  void _processStateActions(MonitoringState state, BGLDataModel data) {
    // بناءً على الحالة، يتم استدعاء ميثودات خدمة الطوارئ
    switch (state) {
      case MonitoringState.criticalEmergency:
        _emergencyService.triggerEmergencyCallAndSMS(data.bgl);
        break;
      case MonitoringState.acuteRisk:
        _emergencyService.sendAcuteRiskSMS(data.bgl);
        break;
      case MonitoringState.preAlert:
        _emergencyService.sendPreAlertNotification(data.bgl);
        break;
      case MonitoringState.stable:
        // لا يوجد إجراء طارئ، فقط تسجيل البيانات
        break;
    }
  }

  // ميثود لإرسال الأمر إلى الحافة (عبر BLE)
  void _sendControlCommand(MonitoringState state, String deviceID) {
    int interval;
    String powerMode;

    // تحديد الفاصل الزمني بناءً على الحالة
    switch (state) {
      case MonitoringState.criticalEmergency:
        interval = 30;
        powerMode = 'High';
        break;
      case MonitoringState.acuteRisk:
        interval = 60;
        powerMode = 'High';
        break;
      case MonitoringState.preAlert:
        interval = 300;
        powerMode = 'Standard';
        break;
      case MonitoringState.stable:
        interval = 900;
        powerMode = 'Low';
        break;
    }

    // بناء رسالة التحكم وإرسالها عبر BLE
    final commandPayload = {
      'Command': 'SET_INTERVAL',
      'NewInterval': interval,
      'PowerMode': powerMode,
    };
    
    _bleService.sendCommand(commandPayload);
  }
}

