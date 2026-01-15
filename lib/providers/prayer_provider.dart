import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/prayer_model.dart';
import '../services/database_service.dart';
import '../utils/helpers.dart';

class PrayerProvider with ChangeNotifier {
  final DatabaseService _databaseService;
  List<PrayerCount> _prayerCounts = [];
  List<PrayerLog> _prayerLogs = [];
  DailyStatistics? _todayStatistics;
  DateTime _lastResetDate = DateTime.now();

  PrayerProvider(this._databaseService);

  // Getters
  List<PrayerCount> get prayerCounts => _prayerCounts;
  List<PrayerLog> get prayerLogs => _prayerLogs;
  DailyStatistics? get todayStatistics => _todayStatistics;

  // Initialize
  Future<void> initialize() async {
    await _loadPrayerCounts();
    await _loadTodayStatistics();
    await _loadPrayerLogs();
  }

  Future<void> _loadPrayerCounts() async {
    _prayerCounts = await _databaseService.getPrayerCounts();
    notifyListeners();
  }

  Future<void> _loadTodayStatistics() async {
    final today = DateTime.now();
    _todayStatistics = await _databaseService.getDailyStatistics(today);
    notifyListeners();
  }

  Future<void> _loadPrayerLogs() async {
    _prayerLogs = await _databaseService.getPrayerLogs();
    notifyListeners();
  }

  // Setup initial prayer counts
  Future<void> setupInitialCounts(Map<String, int> counts) async {
    for (final entry in counts.entries) {
      await _databaseService.updatePrayerCount(entry.key, entry.value);
    }
    await _loadPrayerCounts();
    notifyListeners();
  }

  // Pray (decrease count and log)
  Future<bool> decreasePrayerCount(String prayerName) async {
    try {
      final currentCount = await _databaseService.getPrayerCount(prayerName);
      
      if (currentCount <= 0) {
        return false;
      }

      final newCount = currentCount - 1;
      await _databaseService.updatePrayerCount(prayerName, newCount);

      // Add log
      final now = DateTime.now();
      final log = PrayerLog(
        prayerName: prayerName,
        dateLogged: now,
        timeLogged: formatTime(now),
      );
      await _databaseService.addPrayerLog(log);

      // Update today's statistics
      await _updateTodayStatistics(prayerName, increment: true);

      await _loadPrayerCounts();
      await _loadPrayerLogs();
      await _loadTodayStatistics();
      notifyListeners();
      return true;
    } catch (e) {
      print('Error decreasing prayer count: $e');
      return false;
    }
  }

  Future<void> _updateTodayStatistics(String prayerName, {required bool increment}) async {
    final today = DateTime.now();
    final stats = await _databaseService.getDailyStatistics(today);
    
    late DailyStatistics updatedStats;
    if (increment) {
      updatedStats = stats.copyWith(
        fajrCount: prayerName == 'Fajr' ? stats.fajrCount + 1 : stats.fajrCount,
        dhuhrCount: prayerName == 'Dhuhr' ? stats.dhuhrCount + 1 : stats.dhuhrCount,
        asrCount: prayerName == 'Asr' ? stats.asrCount + 1 : stats.asrCount,
        maghribCount: prayerName == 'Maghrib' ? stats.maghribCount + 1 : stats.maghribCount,
        ishaCount: prayerName == 'Isha' ? stats.ishaCount + 1 : stats.ishaCount,
      );
    } else {
      updatedStats = stats.copyWith(
        fajrCount: prayerName == 'Fajr' ? (stats.fajrCount > 0 ? stats.fajrCount - 1 : 0) : stats.fajrCount,
        dhuhrCount: prayerName == 'Dhuhr' ? (stats.dhuhrCount > 0 ? stats.dhuhrCount - 1 : 0) : stats.dhuhrCount,
        asrCount: prayerName == 'Asr' ? (stats.asrCount > 0 ? stats.asrCount - 1 : 0) : stats.asrCount,
        maghribCount: prayerName == 'Maghrib' ? (stats.maghribCount > 0 ? stats.maghribCount - 1 : 0) : stats.maghribCount,
        ishaCount: prayerName == 'Isha' ? (stats.ishaCount > 0 ? stats.ishaCount - 1 : 0) : stats.ishaCount,
      );
    }
    
    await _databaseService.updateDailyStatistics(updatedStats);
  }

  // Get prayer logs with filters
  Future<void> loadPrayerLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? prayerName,
  }) async {
    _prayerLogs = await _databaseService.getPrayerLogs(
      startDate: startDate,
      endDate: endDate,
      prayerName: prayerName,
    );
    notifyListeners();
  }

  // Delete prayer log
  Future<void> deletePrayerLog(int id) async {
    await _databaseService.deletePrayerLog(id);
    await _loadPrayerLogs();
    notifyListeners();
  }

  // Get statistics for a specific date
  Future<DailyStatistics> getStatistics(DateTime date) async {
    return await _databaseService.getDailyStatistics(date);
  }

  // Reset if new day
  Future<void> checkAndResetDailyStats() async {
    final now = DateTime.now();
    if (!isSameDay(_lastResetDate, now)) {
      _lastResetDate = now;
      await _loadTodayStatistics();
    }
  }
}
