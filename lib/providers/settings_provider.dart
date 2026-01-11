import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:diabetes_fog_app/models/settings_model.dart';
import 'package:diabetes_fog_app/models/watcher_model.dart';
import 'package:diabetes_fog_app/services/database_service.dart';

// Provider للإعدادات
final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsModel?>((ref) {
  return SettingsNotifier();
});

class SettingsNotifier extends StateNotifier<SettingsModel?> {
  final DatabaseService _databaseService = DatabaseService();

  SettingsNotifier() : super(null) {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _databaseService.getSettings();
    if (settings == null) {
      // إذا لم تكن هناك إعدادات، أنشئ إعدادات افتراضية واحفظها
      final defaultSettings = SettingsModel(
        safetyRangeMin: 90.0,
        safetyRangeMax: 180.0,
        acuteRiskLowMin: 54.0,
        acuteRiskLowMax: 70.0,
        acuteRiskHighMin: 250.0,
        acuteRiskHighMax: 300.0,
      );
      await _databaseService.saveSettings(defaultSettings);
      state = defaultSettings;
    } else {
      state = settings;
    }
  }

  Future<void> updateSettings(SettingsModel settings) async {
    await _databaseService.saveSettings(settings);
    state = settings;
  }

  Future<void> refresh() async {
    await _loadSettings();
  }
}

// Provider للمراقبين
final watchersProvider = StateNotifierProvider<WatchersNotifier, List<WatcherModel>>((ref) {
  return WatchersNotifier();
});

class WatchersNotifier extends StateNotifier<List<WatcherModel>> {
  final DatabaseService _databaseService = DatabaseService();

  WatchersNotifier() : super([]) {
    _loadWatchers();
  }

  Future<void> _loadWatchers() async {
    final watchers = await _databaseService.getAllWatchers();
    state = watchers;
  }

  Future<void> addWatcher(WatcherModel watcher) async {
    await _databaseService.insertWatcher(watcher);
    await _loadWatchers();
  }

  Future<void> deleteWatcher(int id) async {
    await _databaseService.deleteWatcher(id);
    await _loadWatchers();
  }

  Future<void> refresh() async {
    await _loadWatchers();
  }
}

