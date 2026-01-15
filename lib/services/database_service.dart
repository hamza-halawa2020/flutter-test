import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../models/prayer_model.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'qadaa_tracker.db');
    
    return openDatabase(
      path,
      version: 2,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Prayer counts table
    await db.execute('''
      CREATE TABLE prayer_counts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prayer_name TEXT UNIQUE NOT NULL,
        count INTEGER NOT NULL
      )
    ''');

    // Prayer logs table (Feature 9: Added fields for editing)
    await db.execute('''
      CREATE TABLE prayer_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        prayer_name TEXT NOT NULL,
        date_logged TEXT NOT NULL,
        time_logged TEXT NOT NULL,
        timestamp INTEGER NOT NULL,
        time_of_day TEXT,
        notes TEXT,
        is_edited INTEGER DEFAULT 0
      )
    ''');

    // Daily statistics table
    await db.execute('''
      CREATE TABLE daily_statistics (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT UNIQUE NOT NULL,
        fajr_count INTEGER NOT NULL DEFAULT 0,
        dhuhr_count INTEGER NOT NULL DEFAULT 0,
        asr_count INTEGER NOT NULL DEFAULT 0,
        maghrib_count INTEGER NOT NULL DEFAULT 0,
        isha_count INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // Initialize prayer counts
    final prayers = ['Fajr', 'Dhuhr', 'Asr', 'Maghrib', 'Isha'];
    for (final prayer in prayers) {
      await db.insert('prayer_counts', {
        'prayer_name': prayer,
        'count': 0,
      });
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add new columns for Feature 9
      try {
        await db.execute('ALTER TABLE prayer_logs ADD COLUMN time_of_day TEXT');
      } catch (e) {
        print('Column time_of_day already exists');
      }
      try {
        await db.execute('ALTER TABLE prayer_logs ADD COLUMN notes TEXT');
      } catch (e) {
        print('Column notes already exists');
      }
      try {
        await db.execute('ALTER TABLE prayer_logs ADD COLUMN is_edited INTEGER DEFAULT 0');
      } catch (e) {
        print('Column is_edited already exists');
      }
    }
  }

  // Prayer Count Operations
  Future<List<PrayerCount>> getPrayerCounts() async {
    final db = await database;
    final maps = await db.query('prayer_counts', orderBy: 'id ASC');
    return List.generate(maps.length, (i) {
      return PrayerCount(
        prayerName: maps[i]['prayer_name'] as String,
        count: maps[i]['count'] as int,
      );
    });
  }

  Future<void> updatePrayerCount(String prayerName, int count) async {
    final db = await database;
    if (count < 0) count = 0;
    
    await db.update(
      'prayer_counts',
      {'count': count},
      where: 'prayer_name = ?',
      whereArgs: [prayerName],
    );
  }

  Future<int> getPrayerCount(String prayerName) async {
    final db = await database;
    final result = await db.query(
      'prayer_counts',
      where: 'prayer_name = ?',
      whereArgs: [prayerName],
    );
    if (result.isEmpty) return 0;
    return result.first['count'] as int;
  }

  // Prayer Log Operations
  Future<int> addPrayerLog(PrayerLog log) async {
    final db = await database;
    return await db.insert('prayer_logs', {
      'prayer_name': log.prayerName,
      'date_logged': log.dateLogged.toIso8601String(),
      'time_logged': log.timeLogged,
      'timestamp': log.dateLogged.millisecondsSinceEpoch,
      'time_of_day': log.timeOfDay,
      'notes': log.notes,
      'is_edited': log.isEdited ?? false ? 1 : 0,
    });
  }

  // Feature 9: Update prayer log
  Future<bool> updatePrayerLog(PrayerLog log) async {
    try {
      final db = await database;
      await db.update(
        'prayer_logs',
        {
          'prayer_name': log.prayerName,
          'date_logged': log.dateLogged.toIso8601String(),
          'time_logged': log.timeLogged,
          'timestamp': log.dateLogged.millisecondsSinceEpoch,
          'time_of_day': log.timeOfDay,
          'notes': log.notes,
          'is_edited': 1,
        },
        where: 'id = ?',
        whereArgs: [log.id],
      );
      return true;
    } catch (e) {
      print('Error updating prayer log: $e');
      return false;
    }
  }

  Future<List<PrayerLog>> getPrayerLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? prayerName,
  }) async {
    final db = await database;
    String whereClause = '';
    List<dynamic> whereArgs = [];

    if (startDate != null) {
      whereClause += 'date_logged >= ?';
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'date_logged <= ?';
      whereArgs.add(endDate.toIso8601String());
    }

    if (prayerName != null) {
      if (whereClause.isNotEmpty) whereClause += ' AND ';
      whereClause += 'prayer_name = ?';
      whereArgs.add(prayerName);
    }

    final maps = await db.query(
      'prayer_logs',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      return PrayerLog(
        id: maps[i]['id'] as int,
        prayerName: maps[i]['prayer_name'] as String,
        dateLogged: DateTime.parse(maps[i]['date_logged'] as String),
        timeLogged: maps[i]['time_logged'] as String,
        timeOfDay: maps[i]['time_of_day'] as String?,
        notes: maps[i]['notes'] as String?,
        isEdited: (maps[i]['is_edited'] as int?) == 1,
      );
    });
  }

  Future<void> deletePrayerLog(int id) async {
    final db = await database;
    await db.delete(
      'prayer_logs',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Daily Statistics Operations
  Future<DailyStatistics> getDailyStatistics(DateTime date) async {
    final db = await database;
    final dateStr = date.toString().split(' ')[0];
    
    final result = await db.query(
      'daily_statistics',
      where: 'date = ?',
      whereArgs: [dateStr],
    );

    if (result.isEmpty) {
      final stats = DailyStatistics(date: date);
      await db.insert('daily_statistics', {
        'date': dateStr,
        'fajr_count': 0,
        'dhuhr_count': 0,
        'asr_count': 0,
        'maghrib_count': 0,
        'isha_count': 0,
      });
      return stats;
    }

    return DailyStatistics(
      date: date,
      fajrCount: result.first['fajr_count'] as int,
      dhuhrCount: result.first['dhuhr_count'] as int,
      asrCount: result.first['asr_count'] as int,
      maghribCount: result.first['maghrib_count'] as int,
      ishaCount: result.first['isha_count'] as int,
    );
  }

  Future<void> updateDailyStatistics(DailyStatistics stats) async {
    final db = await database;
    final dateStr = stats.date.toString().split(' ')[0];

    await db.update(
      'daily_statistics',
      {
        'fajr_count': stats.fajrCount,
        'dhuhr_count': stats.dhuhrCount,
        'asr_count': stats.asrCount,
        'maghrib_count': stats.maghribCount,
        'isha_count': stats.ishaCount,
      },
      where: 'date = ?',
      whereArgs: [dateStr],
    );
  }

  Future<void> resetDailyStatistics(DateTime date) async {
    final db = await database;
    final dateStr = date.toString().split(' ')[0];

    await db.update(
      'daily_statistics',
      {
        'fajr_count': 0,
        'dhuhr_count': 0,
        'asr_count': 0,
        'maghrib_count': 0,
        'isha_count': 0,
      },
      where: 'date = ?',
      whereArgs: [dateStr],
    );
  }

  // Backup/Restore Operations
  Future<Map<String, dynamic>> getAllData() async {
    final db = await database;
    
    final prayerCounts = await db.query('prayer_counts');
    final prayerLogs = await db.query('prayer_logs');
    final dailyStats = await db.query('daily_statistics');

    return {
      'prayer_counts': prayerCounts,
      'prayer_logs': prayerLogs,
      'daily_statistics': dailyStats,
      'version': 1,
      'backup_date': DateTime.now().toIso8601String(),
    };
  }

  Future<bool> restoreData(Map<String, dynamic> data) async {
    try {
      final db = await database;

      // Clear existing data
      await db.delete('prayer_counts');
      await db.delete('prayer_logs');
      await db.delete('daily_statistics');

      // Restore prayer counts
      for (final count in data['prayer_counts'] ?? []) {
        await db.insert('prayer_counts', count);
      }

      // Restore prayer logs
      for (final log in data['prayer_logs'] ?? []) {
        await db.insert('prayer_logs', log);
      }

      // Restore daily statistics
      for (final stat in data['daily_statistics'] ?? []) {
        await db.insert('daily_statistics', stat);
      }

      return true;
    } catch (e) {
      print('Error restoring data: $e');
      return false;
    }
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('prayer_counts');
    await db.delete('prayer_logs');
    await db.delete('daily_statistics');
  }
}
