import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/providers/settings_provider.dart';
import 'package:diabetes_fog_app/l10n/app_localizations.dart';

class RiskThresholdsSection extends ConsumerStatefulWidget {
  const RiskThresholdsSection({super.key});

  @override
  ConsumerState<RiskThresholdsSection> createState() => _RiskThresholdsSectionState();
}

class _RiskThresholdsSectionState extends ConsumerState<RiskThresholdsSection> {
  final _safetyMinController = TextEditingController();
  final _safetyMaxController = TextEditingController();
  final _acuteLowMinController = TextEditingController();
  final _acuteLowMaxController = TextEditingController();
  final _acuteHighMinController = TextEditingController();
  final _acuteHighMaxController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // استخدام WidgetsBinding.instance.addPostFrameCallback للتأكد من تحميل البيانات بعد بناء الواجهة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSettings();
    });
  }

  Future<void> _loadSettings() async {
    // التأكد من تحميل الإعدادات من قاعدة البيانات
    await ref.read(settingsProvider.notifier).refresh();
    final settings = ref.read(settingsProvider);
    
    // استخدام القيم الافتراضية إذا كانت الإعدادات null
    final safetyMin = settings?.safetyRangeMin ?? 90.0;
    final safetyMax = settings?.safetyRangeMax ?? 180.0;
    final acuteLowMin = settings?.acuteRiskLowMin ?? 54.0;
    final acuteLowMax = settings?.acuteRiskLowMax ?? 70.0;
    final acuteHighMin = settings?.acuteRiskHighMin ?? 250.0;
    final acuteHighMax = settings?.acuteRiskHighMax ?? 300.0;
    
    setState(() {
      _safetyMinController.text = safetyMin.toStringAsFixed(0);
      _safetyMaxController.text = safetyMax.toStringAsFixed(0);
      _acuteLowMinController.text = acuteLowMin.toStringAsFixed(0);
      _acuteLowMaxController.text = acuteLowMax.toStringAsFixed(0);
      _acuteHighMinController.text = acuteHighMin.toStringAsFixed(0);
      _acuteHighMaxController.text = acuteHighMax.toStringAsFixed(0);
    });
  }

  @override
  void dispose() {
    _safetyMinController.dispose();
    _safetyMaxController.dispose();
    _acuteLowMinController.dispose();
    _acuteLowMaxController.dispose();
    _acuteHighMinController.dispose();
    _acuteHighMaxController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  l10n.riskThresholds,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // نطاق الأمان
            Text(
              l10n.safetyRange,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _safetyMinController,
                    decoration: InputDecoration(
                      labelText: l10n.min,
                      prefixText: 'mg/dL: ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _safetyMaxController,
                    decoration: InputDecoration(
                      labelText: l10n.max,
                      prefixText: 'mg/dL: ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // عتبة الخطر الحاد
            Text(
              l10n.acuteRiskThresholds,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            
            // النطاق المنخفض
            Text(
              l10n.lowRange,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _acuteLowMinController,
                    decoration: InputDecoration(
                      labelText: l10n.min,
                      prefixText: 'mg/dL: ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _acuteLowMaxController,
                    decoration: InputDecoration(
                      labelText: l10n.max,
                      prefixText: 'mg/dL: ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // النطاق العالي
            Text(
              l10n.highRange,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _acuteHighMinController,
                    decoration: InputDecoration(
                      labelText: l10n.min,
                      prefixText: 'mg/dL: ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _acuteHighMaxController,
                    decoration: InputDecoration(
                      labelText: l10n.max,
                      prefixText: 'mg/dL: ',
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // زر الحفظ
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveThresholds,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF041E76),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: Text(l10n.save),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveThresholds() async {
    try {
      final settings = ref.read(settingsProvider);
      if (settings != null) {
        await ref.read(settingsProvider.notifier).updateSettings(
              settings.copyWith(
                safetyRangeMin: double.parse(_safetyMinController.text),
                safetyRangeMax: double.parse(_safetyMaxController.text),
                acuteRiskLowMin: double.parse(_acuteLowMinController.text),
                acuteRiskLowMax: double.parse(_acuteLowMaxController.text),
                acuteRiskHighMin: double.parse(_acuteHighMinController.text),
                acuteRiskHighMax: double.parse(_acuteHighMaxController.text),
              ),
            );
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Thresholds saved successfully')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: Invalid input - $e')),
        );
      }
    }
  }
}

