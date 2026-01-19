import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/providers/settings_provider.dart';
import 'package:diabetes_fog_app/providers/test_data_provider.dart';
import 'package:diabetes_fog_app/providers/locale_provider.dart';
import 'package:diabetes_fog_app/services/emergency_service.dart';
import 'package:diabetes_fog_app/services/database_service.dart';
import 'package:diabetes_fog_app/l10n/app_localizations.dart';
import 'package:diabetes_fog_app/models/monitoring_state.dart';

class SystemTestingSection extends ConsumerWidget {
  const SystemTestingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bug_report, color: Colors.purple),
                const SizedBox(width: 8),
                Text(
                  l10n.systemTesting,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Text(
              'Test the emergency call functionality to ensure it works correctly with the pre-recorded voice message.',
              style: TextStyle(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _testEmergencyCall(context, ref, settings),
                icon: const Icon(Icons.phone),
                label: Text(l10n.testEmergencyCall),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // قسم اختبار إرسال البيانات
            Divider(color: Colors.grey[300]),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.send, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'اختبار إرسال البيانات',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'إرسال بيانات تجريبية بشكل دوري لاختبار API. البيانات تُرسل كل 10 ثوانٍ وتتناوب بين الحالات الأربعة.',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
            const SizedBox(height: 16),
            
            // حالة الإرسال التجريبي
            Consumer(
              builder: (context, ref, child) {
                final testState = ref.watch(testDataProvider);
                final isArabic = ref.watch(localeProvider).languageCode == 'ar';
                
                return Column(
                  children: [
                    // مؤشر الحالة
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: testState.isRunning 
                            ? Colors.green[50] 
                            : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: testState.isRunning 
                              ? Colors.green 
                              : Colors.grey,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            testState.isRunning 
                                ? Icons.play_circle_filled 
                                : Icons.stop_circle,
                            color: testState.isRunning 
                                ? Colors.green 
                                : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  testState.isRunning 
                                      ? (isArabic ? 'جاري الإرسال...' : 'Sending...')
                                      : (isArabic ? 'متوقف' : 'Stopped'),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: testState.isRunning 
                                        ? Colors.green[700] 
                                        : Colors.grey[700],
                                  ),
                                ),
                                if (testState.isRunning) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    isArabic 
                                        ? 'الحالة الحالية: ${testState.currentTestState.displayNameAr}'
                                        : 'Current State: ${testState.currentTestState.displayName}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  Text(
                                    isArabic 
                                        ? 'عدد البيانات المرسلة: ${testState.sentCount}'
                                        : 'Sent: ${testState.sentCount}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (testState.lastError != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.red[300]!),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, 
                                 color: Colors.red[700], 
                                 size: 16),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                testState.lastError!,
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 16),
                    
                    // زر بدء/إيقاف
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: testState.isRunning
                            ? () => ref.read(testDataProvider.notifier).stopTestSending()
                            : () => ref.read(testDataProvider.notifier).startTestSending(),
                        icon: Icon(
                          testState.isRunning 
                              ? Icons.stop 
                              : Icons.play_arrow,
                        ),
                        label: Text(
                          testState.isRunning 
                              ? (isArabic ? 'إيقاف الإرسال' : 'Stop Sending')
                              : (isArabic ? 'بدء الإرسال التجريبي' : 'Start Test Sending'),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: testState.isRunning 
                              ? Colors.red 
                              : Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _testEmergencyCall(
    BuildContext context,
    WidgetRef ref,
    settings,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    
    // إعادة تحميل الإعدادات من قاعدة البيانات للتأكد من الحصول على أحدث البيانات
    await ref.read(settingsProvider.notifier).refresh();
    final currentSettings = ref.read(settingsProvider);
    
    // التحقق من وجود رقم الطوارئ
    String? emergencyNumber;
    if (settings != null && settings.emergencyNumber != null && settings.emergencyNumber!.isNotEmpty) {
      emergencyNumber = settings.emergencyNumber;
    } else if (currentSettings != null && currentSettings.emergencyNumber != null && currentSettings.emergencyNumber!.isNotEmpty) {
      emergencyNumber = currentSettings.emergencyNumber;
    } else {
      // محاولة أخيرة: تحميل مباشر من قاعدة البيانات
      final dbService = DatabaseService();
      final dbSettings = await dbService.getSettings();
      if (dbSettings?.emergencyNumber != null && dbSettings!.emergencyNumber!.isNotEmpty) {
        emergencyNumber = dbSettings.emergencyNumber;
      }
    }

    if (emergencyNumber == null || emergencyNumber.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseSetEmergencyNumber),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    try {
      final emergencyService = EmergencyService();
      await emergencyService.testEmergencyCall(emergencyNumber);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.emergencyCallTestInitiated),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.error}: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

