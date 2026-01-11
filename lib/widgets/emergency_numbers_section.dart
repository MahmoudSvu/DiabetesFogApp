import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/providers/settings_provider.dart';
import 'package:diabetes_fog_app/models/watcher_model.dart';
import 'package:diabetes_fog_app/l10n/app_localizations.dart';

class EmergencyNumbersSection extends ConsumerStatefulWidget {
  const EmergencyNumbersSection({super.key});

  @override
  ConsumerState<EmergencyNumbersSection> createState() => _EmergencyNumbersSectionState();
}

class _EmergencyNumbersSectionState extends ConsumerState<EmergencyNumbersSection> {
  final _emergencyNumberController = TextEditingController();
  final _watcherNameController = TextEditingController();
  final _watcherPhoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = ref.read(settingsProvider);
    if (settings?.emergencyNumber != null) {
      _emergencyNumberController.text = settings!.emergencyNumber!;
    }
  }

  @override
  void dispose() {
    _emergencyNumberController.dispose();
    _watcherNameController.dispose();
    _watcherPhoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final settings = ref.watch(settingsProvider);
    final watchers = ref.watch(watchersProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.emergency, color: Colors.red),
                const SizedBox(width: 8),
                Text(
                  l10n.emergencyNumbers,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // حقل رقم الطوارئ
            TextField(
              controller: _emergencyNumberController,
              decoration: InputDecoration(
                labelText: '${l10n.emergencyNumber} *',
                hintText: '+966501234567',
                prefixIcon: const Icon(Icons.phone),
                suffixIcon: _emergencyNumberController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => _saveEmergencyNumber(),
                      )
                    : null,
              ),
              keyboardType: TextInputType.phone,
              onChanged: (value) {
                setState(() {});
              },
              onSubmitted: (_) => _saveEmergencyNumber(),
            ),
            const SizedBox(height: 24),
            
            // قائمة المراقبين
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.watchers,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _showAddWatcherDialog(context),
                  icon: const Icon(Icons.add),
                  label: Text(l10n.addWatcher),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF041E76),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            // قائمة المراقبين
            watchers.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        'No watchers added yet',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: watchers.length,
                    itemBuilder: (context, index) {
                      final watcher = watchers[index];
                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(watcher.name),
                        subtitle: Text(watcher.phoneNumber),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteWatcher(watcher.id!),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveEmergencyNumber() async {
    final settings = ref.read(settingsProvider);
    if (settings != null) {
      await ref.read(settingsProvider.notifier).updateSettings(
            settings.copyWith(emergencyNumber: _emergencyNumberController.text),
          );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency number saved')),
      );
    }
  }

  void _showAddWatcherDialog(BuildContext context) {
    _watcherNameController.clear();
    _watcherPhoneController.clear();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.addWatcher),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _watcherNameController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.watcherName,
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _watcherPhoneController,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.phoneNumber,
                prefixIcon: const Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              if (_watcherNameController.text.isNotEmpty &&
                  _watcherPhoneController.text.isNotEmpty) {
                ref.read(watchersProvider.notifier).addWatcher(
                      WatcherModel(
                        name: _watcherNameController.text,
                        phoneNumber: _watcherPhoneController.text,
                      ),
                    );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Watcher added')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF041E76),
            ),
            child: Text(AppLocalizations.of(context)!.save),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteWatcher(int id) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Watcher'),
        content: const Text('Are you sure you want to delete this watcher?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.delete),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(watchersProvider.notifier).deleteWatcher(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Watcher deleted')),
      );
    }
  }
}

