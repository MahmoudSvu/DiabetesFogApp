import 'package:diabetes_fog_app/models/monitoring_state.dart';

class EventLogModel {
  final int? id;
  final int timestamp;
  final double bgl;
  final MonitoringState state;
  final String eventType; // 'reading', 'state_change', 'alert', etc.
  final String? message;

  EventLogModel({
    this.id,
    required this.timestamp,
    required this.bgl,
    required this.state,
    required this.eventType,
    this.message,
  });

  factory EventLogModel.fromJson(Map<String, dynamic> json) {
    return EventLogModel(
      id: json['id'] as int?,
      timestamp: json['timestamp'] as int,
      bgl: (json['bgl'] as num).toDouble(),
      state: MonitoringState.values[json['state'] as int],
      eventType: json['eventType'] as String,
      message: json['message'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'timestamp': timestamp,
      'bgl': bgl,
      'state': state.index,
      'eventType': eventType,
      'message': message,
    };
  }
}

