import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/providers/settings_provider.dart';
import 'package:diabetes_fog_app/services/emergency_service.dart';
import 'package:diabetes_fog_app/services/database_service.dart';
import 'package:diabetes_fog_app/l10n/app_localizations.dart';

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

