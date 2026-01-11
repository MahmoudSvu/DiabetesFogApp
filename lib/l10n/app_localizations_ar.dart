// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'مراقبة السكري';

  @override
  String get monitoringDashboard => 'لوحة المراقبة الرئيسية';

  @override
  String get settings => 'الإعدادات';

  @override
  String get currentBGL => 'مستوى الجلوكوز الحالي';

  @override
  String get mgdL => 'ملجم/ديسيلتر';

  @override
  String get trend => 'الاتجاه';

  @override
  String get battery => 'البطارية';

  @override
  String get adaptiveFrequency => 'التردد التكيفي';

  @override
  String get seconds => 'ثانية';

  @override
  String get currentState => 'الحالة الحالية';

  @override
  String get eventLog => 'سجل الأحداث';

  @override
  String get location => 'الموقع';

  @override
  String get emergencyNumbers => 'أرقام الطوارئ';

  @override
  String get emergencyNumber => 'رقم الطوارئ';

  @override
  String get required => 'إلزامي';

  @override
  String get watchers => 'المراقبون';

  @override
  String get addWatcher => 'إضافة مراقب';

  @override
  String get watcherName => 'اسم المراقب';

  @override
  String get phoneNumber => 'رقم الهاتف';

  @override
  String get delete => 'حذف';

  @override
  String get riskThresholds => 'عتبات الخطر';

  @override
  String get safetyRange => 'نطاق الأمان';

  @override
  String get min => 'الحد الأدنى';

  @override
  String get max => 'الحد الأقصى';

  @override
  String get acuteRiskThresholds => 'عتبة الخطر الحاد';

  @override
  String get lowRange => 'النطاق المنخفض';

  @override
  String get highRange => 'النطاق العالي';

  @override
  String get edgeConnectivity => 'الاتصال بالحافة';

  @override
  String get scan => 'بحث';

  @override
  String get deviceID => 'هوية الجهاز';

  @override
  String get systemTesting => 'اختبار النظام';

  @override
  String get testEmergencyCall => 'اختبار الاتصال الآلي';

  @override
  String get save => 'حفظ';

  @override
  String get cancel => 'إلغاء';

  @override
  String get stable => 'مستقر';

  @override
  String get preAlert => 'إنذار مسبق';

  @override
  String get acuteRisk => 'خطر حاد';

  @override
  String get criticalEmergency => 'طوارئ حرجة';

  @override
  String get connecting => 'جاري الاتصال...';

  @override
  String get connected => 'متصل';

  @override
  String get disconnected => 'غير متصل';

  @override
  String get connect => 'اتصال';

  @override
  String get disconnect => 'قطع الاتصال';

  @override
  String get pleaseSetEmergencyNumber => 'يرجى تعيين رقم الطوارئ أولاً';

  @override
  String get emergencyCallTestInitiated => 'تم بدء اختبار الاتصال الآلي';

  @override
  String get error => 'خطأ';

  @override
  String get locationPermissionRequired => 'صلاحية الموقع مطلوبة';

  @override
  String get locationPermissionMessage =>
      'يحتاج التطبيق إلى صلاحية الموقع لإرسال موقعك في حالات الطوارئ. يرجى منح صلاحية الموقع للمتابعة.';

  @override
  String get grantPermission => 'منح الصلاحية';

  @override
  String get skip => 'تخطي';

  @override
  String get locationPermissionDenied =>
      'صلاحية الموقع مطلوبة لميزات الطوارئ. يمكنك تفعيلها لاحقاً من الإعدادات.';

  @override
  String get openSettings => 'فتح الإعدادات';
}
