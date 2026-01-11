import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/widgets/emergency_numbers_section.dart';
import 'package:diabetes_fog_app/widgets/risk_thresholds_section.dart';
import 'package:diabetes_fog_app/widgets/edge_connectivity_section.dart';
import 'package:diabetes_fog_app/widgets/system_testing_section.dart';
import 'package:diabetes_fog_app/l10n/app_localizations.dart';
import 'package:diabetes_fog_app/providers/locale_provider.dart';

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
}

