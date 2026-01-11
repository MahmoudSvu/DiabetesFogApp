import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:diabetes_fog_app/models/settings_model.dart';
import 'package:diabetes_fog_app/models/watcher_model.dart';
import 'package:diabetes_fog_app/models/event_log_model.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'diabetes_fog.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // جدول الإعدادات
    await db.execute('''
      CREATE TABLE settings (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        emergencyNumber TEXT,
        safetyRangeMin REAL DEFAULT 90.0,
        safetyRangeMax REAL DEFAULT 180.0,
        acuteRiskLowMin REAL DEFAULT 54.0,
        acuteRiskLowMax REAL DEFAULT 70.0,
        acuteRiskHighMin REAL DEFAULT 250.0,
        acuteRiskHighMax REAL DEFAULT 300.0,
        deviceID TEXT,
        apiBaseUrl TEXT
      )
    ''');

    // جدول المراقبين
    await db.execute('''
      CREATE TABLE watchers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        phoneNumber TEXT NOT NULL
      )
    ''');

    // جدول سجل الأحداث
    await db.execute('''
      CREATE TABLE event_log (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp INTEGER NOT NULL,
        bgl REAL NOT NULL,
        state INTEGER NOT NULL,
        eventType TEXT NOT NULL,
        message TEXT
      )
    ''');

    // إدراج إعدادات افتراضية عند إنشاء قاعدة البيانات لأول مرة
    await db.insert('settings', {
      'safetyRangeMin': 90.0,
      'safetyRangeMax': 180.0,
      'acuteRiskLowMin': 54.0,
      'acuteRiskLowMax': 70.0,
      'acuteRiskHighMin': 250.0,
      'acuteRiskHighMax': 300.0,
    });
  }

  // ========== Settings Methods ==========
  Future<SettingsModel?> getSettings() async {
    final db = await database;
    final maps = await db.query('settings', limit: 1);
    if (maps.isEmpty) return null;
    return SettingsModel.fromJson(Map<String, dynamic>.from(maps.first));
  }

  Future<void> saveSettings(SettingsModel settings) async {
    final db = await database;
    final existing = await getSettings();
    final settingsJson = settings.toJson();
    // إزالة id من JSON إذا كان null لتجنب مشاكل في الإدراج
    settingsJson.remove('id');
    
    if (existing == null) {
      await db.insert('settings', settingsJson);
    } else {
      await db.update('settings', settingsJson, where: 'id = ?', whereArgs: [1]);
    }
  }

  // ========== Watchers Methods ==========
  Future<List<WatcherModel>> getAllWatchers() async {
    final db = await database;
    final maps = await db.query('watchers', orderBy: 'name');
    return maps.map((map) => WatcherModel.fromJson(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertWatcher(WatcherModel watcher) async {
    final db = await database;
    return await db.insert('watchers', watcher.toJson());
  }

  Future<int> deleteWatcher(int id) async {
    final db = await database;
    return await db.delete('watchers', where: 'id = ?', whereArgs: [id]);
  }

  // ========== Event Log Methods ==========
  Future<List<EventLogModel>> getRecentEvents({int limit = 50}) async {
    final db = await database;
    final maps = await db.query(
      'event_log',
      orderBy: 'timestamp DESC',
      limit: limit,
    );
    return maps.map((map) => EventLogModel.fromJson(Map<String, dynamic>.from(map))).toList();
  }

  Future<int> insertEvent(EventLogModel event) async {
    final db = await database;
    return await db.insert('event_log', event.toJson());
  }

  Future<void> clearOldEvents({int daysToKeep = 30}) async {
    final db = await database;
    final cutoffTime = DateTime.now().subtract(Duration(days: daysToKeep)).millisecondsSinceEpoch;
    await db.delete('event_log', where: 'timestamp < ?', whereArgs: [cutoffTime]);
  }
}

