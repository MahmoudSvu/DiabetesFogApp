import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/models/bgl_data_model.dart';
import 'package:diabetes_fog_app/models/monitoring_state.dart';
import 'package:diabetes_fog_app/services/fog_orchestrator.dart';
import 'package:diabetes_fog_app/services/emergency_service.dart';
import 'package:diabetes_fog_app/services/ble_service.dart';
import 'package:diabetes_fog_app/services/database_service.dart';
import 'package:diabetes_fog_app/models/event_log_model.dart';

// Provider لخدمة BLE
final bleServiceProvider = Provider<BleService>((ref) {
  return BleService();
});

// Provider لخدمة الطوارئ
final emergencyServiceProvider = Provider<EmergencyService>((ref) {
  return EmergencyService();
});

// Provider لمنسق الضباب
final fogOrchestratorProvider = Provider<FogOrchestrator>((ref) {
  final emergencyService = ref.watch(emergencyServiceProvider);
  final bleService = ref.watch(bleServiceProvider);
  return FogOrchestrator(emergencyService, bleService);
});

// Provider لبيانات BGL الحالية
final currentBGLProvider = StateProvider<BGLDataModel?>((ref) => null);

// Provider لحالة النظام الحالية
final currentStateProvider = StateProvider<MonitoringState>((ref) {
  return MonitoringState.stable;
});

// Provider لمؤشر التردد التكيفي
final adaptiveIntervalProvider = Provider<int>((ref) {
  final state = ref.watch(currentStateProvider);
  switch (state) {
    case MonitoringState.criticalEmergency:
      return 30;
    case MonitoringState.acuteRisk:
      return 60;
    case MonitoringState.preAlert:
      return 300;
    case MonitoringState.stable:
      return 900;
  }
});

// Provider لسجل الأحداث
final eventLogProvider = StateNotifierProvider<EventLogNotifier, List<EventLogModel>>((ref) {
  return EventLogNotifier();
});

class EventLogNotifier extends StateNotifier<List<EventLogModel>> {
  final DatabaseService _databaseService = DatabaseService();

  EventLogNotifier() : super([]) {
    _loadEvents();
  }

  Future<void> _loadEvents() async {
    final events = await _databaseService.getRecentEvents();
    state = events;
  }

  Future<void> addEvent(EventLogModel event) async {
    await _databaseService.insertEvent(event);
    await _loadEvents();
  }

  Future<void> refresh() async {
    await _loadEvents();
  }
}

