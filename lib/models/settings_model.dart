class SettingsModel {
  final String? emergencyNumber;
  final double safetyRangeMin;
  final double safetyRangeMax;
  final double acuteRiskLowMin;
  final double acuteRiskLowMax;
  final double acuteRiskHighMin;
  final double acuteRiskHighMax;
  final String? deviceID;
  final String? apiBaseUrl;

  SettingsModel({
    this.emergencyNumber,
    this.safetyRangeMin = 90.0,
    this.safetyRangeMax = 180.0,
    this.acuteRiskLowMin = 54.0,
    this.acuteRiskLowMax = 70.0,
    this.acuteRiskHighMin = 250.0,
    this.acuteRiskHighMax = 300.0,
    this.deviceID,
    this.apiBaseUrl,
  });

  factory SettingsModel.fromJson(Map<String, dynamic> json) {
    return SettingsModel(
      emergencyNumber: json['emergencyNumber'] as String?,
      safetyRangeMin: (json['safetyRangeMin'] as num?)?.toDouble() ?? 90.0,
      safetyRangeMax: (json['safetyRangeMax'] as num?)?.toDouble() ?? 180.0,
      acuteRiskLowMin: (json['acuteRiskLowMin'] as num?)?.toDouble() ?? 54.0,
      acuteRiskLowMax: (json['acuteRiskLowMax'] as num?)?.toDouble() ?? 70.0,
      acuteRiskHighMin: (json['acuteRiskHighMin'] as num?)?.toDouble() ?? 250.0,
      acuteRiskHighMax: (json['acuteRiskHighMax'] as num?)?.toDouble() ?? 300.0,
      deviceID: json['deviceID'] as String?,
      apiBaseUrl: json['apiBaseUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emergencyNumber': emergencyNumber,
      'safetyRangeMin': safetyRangeMin,
      'safetyRangeMax': safetyRangeMax,
      'acuteRiskLowMin': acuteRiskLowMin,
      'acuteRiskLowMax': acuteRiskLowMax,
      'acuteRiskHighMin': acuteRiskHighMin,
      'acuteRiskHighMax': acuteRiskHighMax,
      'deviceID': deviceID,
      'apiBaseUrl': apiBaseUrl,
    };
  }

  SettingsModel copyWith({
    String? emergencyNumber,
    double? safetyRangeMin,
    double? safetyRangeMax,
    double? acuteRiskLowMin,
    double? acuteRiskLowMax,
    double? acuteRiskHighMin,
    double? acuteRiskHighMax,
    String? deviceID,
    String? apiBaseUrl,
  }) {
    return SettingsModel(
      emergencyNumber: emergencyNumber ?? this.emergencyNumber,
      safetyRangeMin: safetyRangeMin ?? this.safetyRangeMin,
      safetyRangeMax: safetyRangeMax ?? this.safetyRangeMax,
      acuteRiskLowMin: acuteRiskLowMin ?? this.acuteRiskLowMin,
      acuteRiskLowMax: acuteRiskLowMax ?? this.acuteRiskLowMax,
      acuteRiskHighMin: acuteRiskHighMin ?? this.acuteRiskHighMin,
      acuteRiskHighMax: acuteRiskHighMax ?? this.acuteRiskHighMax,
      deviceID: deviceID ?? this.deviceID,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
    );
  }
}

