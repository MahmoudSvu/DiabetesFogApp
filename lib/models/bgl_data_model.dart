class BGLDataModel {
  final String deviceID;
  final int timestamp;
  final double bgl;       // مستوى الجلوكوز في الدم (mg/dL)
  final int trend;        // اتجاه التغير (-2 إلى +2)
  final double battery;   // نسبة بطارية الحافة
  final int status;
  final bool interruptFlag; // مؤشر المقاطعة المحلية

  BGLDataModel({
    required this.deviceID,
    required this.timestamp,
    required this.bgl,
    required this.trend,
    required this.battery,
    required this.status,
    required this.interruptFlag,
  });

  // ميثود لتحويل JSON إلى كائن Dart
  factory BGLDataModel.fromJson(Map<String, dynamic> json) {
    return BGLDataModel(
      deviceID: json['DeviceID'] as String,
      timestamp: json['Timestamp'] as int,
      bgl: (json['BGL'] as num).toDouble(),
      trend: json['Trend'] as int,
      battery: (json['Battery'] as num).toDouble(),
      status: json['Status'] as int,
      interruptFlag: json['InterruptFlag'] as bool? ?? false,
    );
  }

  // ميثود لتحويل الكائن إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'DeviceID': deviceID,
      'Timestamp': timestamp,
      'BGL': bgl,
      'Trend': trend,
      'Battery': battery,
      'Status': status,
      'InterruptFlag': interruptFlag,
    };
  }
}

