import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
  ];

  /// The application title
  ///
  /// In en, this message translates to:
  /// **'Diabetes Monitoring'**
  String get appTitle;

  /// Main monitoring screen title
  ///
  /// In en, this message translates to:
  /// **'Monitoring Dashboard'**
  String get monitoringDashboard;

  /// Settings screen title
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Current blood glucose level label
  ///
  /// In en, this message translates to:
  /// **'Current BGL'**
  String get currentBGL;

  /// Milligrams per deciliter unit
  ///
  /// In en, this message translates to:
  /// **'mg/dL'**
  String get mgdL;

  /// Trend indicator label
  ///
  /// In en, this message translates to:
  /// **'Trend'**
  String get trend;

  /// Battery indicator label
  ///
  /// In en, this message translates to:
  /// **'Battery'**
  String get battery;

  /// Adaptive frequency indicator label
  ///
  /// In en, this message translates to:
  /// **'Adaptive Frequency'**
  String get adaptiveFrequency;

  /// Seconds unit
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// Current monitoring state label
  ///
  /// In en, this message translates to:
  /// **'Current State'**
  String get currentState;

  /// Event log section title
  ///
  /// In en, this message translates to:
  /// **'Event Log'**
  String get eventLog;

  /// Location map section title
  ///
  /// In en, this message translates to:
  /// **'Location'**
  String get location;

  /// Emergency numbers section title
  ///
  /// In en, this message translates to:
  /// **'Emergency Numbers'**
  String get emergencyNumbers;

  /// Emergency number field label
  ///
  /// In en, this message translates to:
  /// **'Emergency Number'**
  String get emergencyNumber;

  /// Required field indicator
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get required;

  /// Watchers list section title
  ///
  /// In en, this message translates to:
  /// **'Watchers'**
  String get watchers;

  /// Add watcher button text
  ///
  /// In en, this message translates to:
  /// **'Add Watcher'**
  String get addWatcher;

  /// Watcher name field label
  ///
  /// In en, this message translates to:
  /// **'Watcher Name'**
  String get watcherName;

  /// Phone number field label
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Delete button text
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Risk thresholds section title
  ///
  /// In en, this message translates to:
  /// **'Risk Thresholds'**
  String get riskThresholds;

  /// Safety range field label
  ///
  /// In en, this message translates to:
  /// **'Safety Range'**
  String get safetyRange;

  /// Minimum value label
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get min;

  /// Maximum value label
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get max;

  /// Acute risk thresholds field label
  ///
  /// In en, this message translates to:
  /// **'Acute Risk Thresholds'**
  String get acuteRiskThresholds;

  /// Low range label
  ///
  /// In en, this message translates to:
  /// **'Low Range'**
  String get lowRange;

  /// High range label
  ///
  /// In en, this message translates to:
  /// **'High Range'**
  String get highRange;

  /// Edge connectivity section title
  ///
  /// In en, this message translates to:
  /// **'Edge Connectivity'**
  String get edgeConnectivity;

  /// Scan for BLE devices button text
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get scan;

  /// Device ID field label
  ///
  /// In en, this message translates to:
  /// **'Device ID'**
  String get deviceID;

  /// System testing section title
  ///
  /// In en, this message translates to:
  /// **'System Testing'**
  String get systemTesting;

  /// Test emergency call button text
  ///
  /// In en, this message translates to:
  /// **'Test Emergency Call'**
  String get testEmergencyCall;

  /// Save button text
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// Cancel button text
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Stable state name
  ///
  /// In en, this message translates to:
  /// **'Stable'**
  String get stable;

  /// Pre-alert state name
  ///
  /// In en, this message translates to:
  /// **'Pre-Alert'**
  String get preAlert;

  /// Acute risk state name
  ///
  /// In en, this message translates to:
  /// **'Acute Risk'**
  String get acuteRisk;

  /// Critical emergency state name
  ///
  /// In en, this message translates to:
  /// **'Critical Emergency'**
  String get criticalEmergency;

  /// Connecting status text
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// Connected status text
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// Disconnected status text
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// Connect button text
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// Disconnect button text
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// Error message when emergency number is not set
  ///
  /// In en, this message translates to:
  /// **'Please set an emergency number first'**
  String get pleaseSetEmergencyNumber;

  /// Success message when emergency call test is started
  ///
  /// In en, this message translates to:
  /// **'Emergency call test initiated'**
  String get emergencyCallTestInitiated;

  /// Error label
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Title for location permission dialog
  ///
  /// In en, this message translates to:
  /// **'Location Permission Required'**
  String get locationPermissionRequired;

  /// Message explaining why location permission is needed
  ///
  /// In en, this message translates to:
  /// **'This app needs location access to send your location in emergency situations. Please grant location permission to continue.'**
  String get locationPermissionMessage;

  /// Button to grant permission
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// Button to skip permission request
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// Message when permission is denied
  ///
  /// In en, this message translates to:
  /// **'Location permission is required for emergency features. You can enable it later in settings.'**
  String get locationPermissionDenied;

  /// Button to open app settings
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
