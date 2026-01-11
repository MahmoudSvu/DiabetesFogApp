// تعريف حالات النظام الأربعة كـ Enum لسهولة الاستخدام
enum MonitoringState {
  stable,          // 1
  preAlert,        // 2
  acuteRisk,       // 3
  criticalEmergency // 4
}

extension MonitoringStateExtension on MonitoringState {
  String get displayName {
    switch (this) {
      case MonitoringState.stable:
        return 'Stable';
      case MonitoringState.preAlert:
        return 'Pre-Alert';
      case MonitoringState.acuteRisk:
        return 'Acute Risk';
      case MonitoringState.criticalEmergency:
        return 'Critical Emergency';
    }
  }
  
  String get displayNameAr {
    switch (this) {
      case MonitoringState.stable:
        return 'مستقر';
      case MonitoringState.preAlert:
        return 'إنذار مسبق';
      case MonitoringState.acuteRisk:
        return 'خطر حاد';
      case MonitoringState.criticalEmergency:
        return 'طوارئ حرجة';
    }
  }
}

