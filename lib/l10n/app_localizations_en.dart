// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Diabetes Monitoring';

  @override
  String get monitoringDashboard => 'Monitoring Dashboard';

  @override
  String get settings => 'Settings';

  @override
  String get currentBGL => 'Current BGL';

  @override
  String get mgdL => 'mg/dL';

  @override
  String get trend => 'Trend';

  @override
  String get battery => 'Battery';

  @override
  String get adaptiveFrequency => 'Adaptive Frequency';

  @override
  String get seconds => 'seconds';

  @override
  String get currentState => 'Current State';

  @override
  String get eventLog => 'Event Log';

  @override
  String get location => 'Location';

  @override
  String get emergencyNumbers => 'Emergency Numbers';

  @override
  String get emergencyNumber => 'Emergency Number';

  @override
  String get required => 'Required';

  @override
  String get watchers => 'Watchers';

  @override
  String get addWatcher => 'Add Watcher';

  @override
  String get watcherName => 'Watcher Name';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get delete => 'Delete';

  @override
  String get riskThresholds => 'Risk Thresholds';

  @override
  String get safetyRange => 'Safety Range';

  @override
  String get min => 'Min';

  @override
  String get max => 'Max';

  @override
  String get acuteRiskThresholds => 'Acute Risk Thresholds';

  @override
  String get lowRange => 'Low Range';

  @override
  String get highRange => 'High Range';

  @override
  String get edgeConnectivity => 'Edge Connectivity';

  @override
  String get scan => 'Scan';

  @override
  String get deviceID => 'Device ID';

  @override
  String get systemTesting => 'System Testing';

  @override
  String get testEmergencyCall => 'Test Emergency Call';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get stable => 'Stable';

  @override
  String get preAlert => 'Pre-Alert';

  @override
  String get acuteRisk => 'Acute Risk';

  @override
  String get criticalEmergency => 'Critical Emergency';

  @override
  String get connecting => 'Connecting...';

  @override
  String get connected => 'Connected';

  @override
  String get disconnected => 'Disconnected';

  @override
  String get connect => 'Connect';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get pleaseSetEmergencyNumber => 'Please set an emergency number first';

  @override
  String get emergencyCallTestInitiated => 'Emergency call test initiated';

  @override
  String get error => 'Error';

  @override
  String get locationPermissionRequired => 'Location Permission Required';

  @override
  String get locationPermissionMessage =>
      'This app needs location access to send your location in emergency situations. Please grant location permission to continue.';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get skip => 'Skip';

  @override
  String get locationPermissionDenied =>
      'Location permission is required for emergency features. You can enable it later in settings.';

  @override
  String get openSettings => 'Open Settings';
}
