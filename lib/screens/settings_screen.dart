import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/widgets/emergency_numbers_section.dart';
import 'package:diabetes_fog_app/widgets/risk_thresholds_section.dart';
import 'package:diabetes_fog_app/widgets/edge_connectivity_section.dart';
import 'package:diabetes_fog_app/widgets/system_testing_section.dart';
import 'package:diabetes_fog_app/l10n/app_localizations.dart';
import 'package:diabetes_fog_app/providers/locale_provider.dart';
import 'package:diabetes_fog_app/providers/auth_provider.dart';
import 'package:diabetes_fog_app/main.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.watch(localeProvider).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.monitor_heart,
              color: Color(0xFF041E76),
              size: 24,
            ),
          ),
        ),
        actions: [
          // زر تغيير اللغة
          IconButton(
            icon: const Icon(Icons.language),
            onPressed: () {
              ref.read(localeProvider.notifier).toggleLocale();
            },
            tooltip: isArabic ? 'Switch to English' : 'التبديل إلى العربية',
          ),
          // زر تسجيل الخروج
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _showLogoutDialog(context, ref),
            tooltip: isArabic ? 'تسجيل الخروج' : 'Logout',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // قسم أرقام الطوارئ
            const EmergencyNumbersSection(),
            const SizedBox(height: 16),
            
            // قسم عتبات الخطر
            const RiskThresholdsSection(),
            const SizedBox(height: 16),
            
            // قسم الاتصال بالحافة
            const EdgeConnectivitySection(),
            const SizedBox(height: 16),
            
            // قسم اختبار النظام
            const SystemTestingSection(),
          ],
        ),
      ),
    );
  }

  static void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final isArabic = ref.read(localeProvider).languageCode == 'ar';
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.logout, color: Colors.red),
            const SizedBox(width: 8),
            Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
          ],
        ),
        content: Text(
          isArabic 
              ? 'هل أنت متأكد من تسجيل الخروج؟ ستحتاج إلى إدخال كود المريض مرة أخرى للدخول.'
              : 'Are you sure you want to logout? You will need to enter your patient code again to login.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await ref.read(authProvider.notifier).logout();
              if (context.mounted) {
                // الانتقال مباشرة إلى شاشة تسجيل الدخول مع مسح كل الصفحات السابقة
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const AppInitializer()),
                  (Route<dynamic> route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(isArabic ? 'تسجيل الخروج' : 'Logout'),
          ),
        ],
      ),
    );
  }
}

