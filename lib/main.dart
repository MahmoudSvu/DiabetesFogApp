import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/l10n/app_localizations.dart';
import 'package:diabetes_fog_app/screens/monitoring_dashboard.dart';
import 'package:diabetes_fog_app/screens/settings_screen.dart';
import 'package:diabetes_fog_app/screens/welcome_screen.dart';
import 'package:diabetes_fog_app/theme/app_theme.dart';
import 'package:diabetes_fog_app/providers/locale_provider.dart';
import 'package:diabetes_fog_app/services/database_service.dart';
import 'package:diabetes_fog_app/services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MaterialApp(
      title: 'مراقبة السكري',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ar', ''), // Arabic (اللغة الأساسية)
        Locale('en', ''), // English
      ],
      home: const AppInitializer(),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  bool _isLoading = true;
  bool _hasSeenWelcome = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // 1. التحقق من حالة شاشة الترحيب
    await _checkWelcomeStatus();
    
    // 2. طلب صلاحيات الموقع عند بدء التطبيق لأول مرة
    if (!_hasSeenWelcome) {
      // نطلب الصلاحيات فقط عند أول تشغيل
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _requestLocationPermission();
      });
    } else {
      // إذا كان المستخدم قد رأى الترحيب من قبل، نتحقق من الصلاحيات فقط
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkLocationPermission();
      });
    }
  }

  Future<void> _checkWelcomeStatus() async {
    final dbService = DatabaseService();
    final settings = await dbService.getSettings();
    // إذا كان deviceID موجوداً وليس 'welcome_seen'، يعني أن المستخدم رأى شاشة الترحيب
    // 'welcome_seen' هو علامة مؤقتة نستخدمها فقط عند رؤية شاشة الترحيب
    final hasSeen = settings?.deviceID != null && 
                    settings!.deviceID!.isNotEmpty && 
                    settings.deviceID != 'welcome_seen';
    
    setState(() {
      _hasSeenWelcome = hasSeen;
      _isLoading = false;
    });
  }

  Future<void> _requestLocationPermission() async {
    if (!mounted) return;
    
    // انتظر قليلاً حتى تكتمل شاشة الترحيب
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    
    // التحقق من الصلاحيات الحالية أولاً
    final status = await PermissionService.checkLocationPermission();
    
    // إذا كانت الصلاحيات مُعطاة بالفعل، لا حاجة لطلبها
    if (status == LocationPermissionStatus.granted) {
      return;
    }
    
    // عرض dialog لطلب الصلاحيات
    if (mounted) {
      final shouldRequest = await _showPermissionRequestDialog();
      if (!shouldRequest) {
        return; // المستخدم اختار تخطي
      }
    }
    
    // طلب الصلاحيات
    final result = await PermissionService.requestLocationPermission();
    
    if (!mounted) return;
    
    // معالجة النتيجة
    switch (result) {
      case LocationPermissionStatus.granted:
        // الصلاحيات مُعطاة بنجاح
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Location permission granted'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
        }
        break;
      case LocationPermissionStatus.denied:
        // الصلاحيات مرفوضة - يمكن للمستخدم تفعيلها لاحقاً
        _showPermissionDeniedSnackBar();
        break;
      case LocationPermissionStatus.deniedForever:
        // الصلاحيات مرفوضة نهائياً - يجب فتح الإعدادات
        _showPermissionDeniedDialog();
        break;
      case LocationPermissionStatus.serviceDisabled:
        // خدمات الموقع معطلة
        _showLocationServiceDisabledDialog();
        break;
      case LocationPermissionStatus.error:
        // خطأ في الطلب
        break;
    }
  }

  Future<bool> _showPermissionRequestDialog() async {
    if (!mounted) return false;
    final l10n = AppLocalizations.of(context);
    
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false, // لا يمكن إغلاقه بالنقر خارج الصندوق
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(
              Icons.location_on,
              color: Color(0xFF041E76),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n?.locationPermissionRequired ?? 'Location Permission Required',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.locationPermissionMessage ?? 
              'This app needs location access to send your location in emergency situations. Please grant location permission to continue.',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF041E76).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF041E76), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your location will only be used in emergency situations to help medical responders find you quickly.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              l10n?.skip ?? 'Skip',
              style: const TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF041E76),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: Text(l10n?.grantPermission ?? 'Grant Permission'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }

  Future<void> _checkLocationPermission() async {
    if (!mounted) return;
    
    final status = await PermissionService.checkLocationPermission();
    
    if (status == LocationPermissionStatus.deniedForever) {
      _showPermissionDeniedDialog();
    } else if (status == LocationPermissionStatus.serviceDisabled) {
      _showLocationServiceDisabledDialog();
    }
  }

  void _showPermissionDeniedSnackBar() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n?.locationPermissionDenied ?? 'Location permission is required for emergency features.'),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: l10n?.openSettings ?? 'Settings',
          textColor: Colors.white,
          onPressed: () => PermissionService.openAppSettings(),
        ),
      ),
    );
  }

  void _showPermissionDeniedDialog() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.locationPermissionRequired ?? 'Location Permission Required'),
        content: Text(l10n?.locationPermissionDenied ?? 'Location permission is required for emergency features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openAppSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF041E76),
            ),
            child: Text(l10n?.openSettings ?? 'Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showLocationServiceDisabledDialog() {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.locationPermissionRequired ?? 'Location Services Disabled'),
        content: const Text('Please enable location services in your device settings to use emergency features.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              PermissionService.openLocationSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF041E76),
            ),
            child: Text(l10n?.openSettings ?? 'Open Settings'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF041E76),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    return _hasSeenWelcome
        ? const MainNavigationScreen()
        : const WelcomeScreen();
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const MonitoringDashboard(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dashboard_outlined),
            selectedIcon: const Icon(Icons.dashboard),
            label: l10n.monitoringDashboard,
          ),
          NavigationDestination(
            icon: const Icon(Icons.settings_outlined),
            selectedIcon: const Icon(Icons.settings),
            label: l10n.settings,
          ),
        ],
      ),
    );
  }
}
