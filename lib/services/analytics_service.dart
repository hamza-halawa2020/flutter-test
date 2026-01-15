import 'package:intl/intl.dart';
import '../models/prayer_model.dart';
import 'database_service.dart';

class AnalyticsService {
  final DatabaseService databaseService;

  AnalyticsService(this.databaseService);

  // Feature 2: Get total stats
  Future<Map<String, int>> getTotalStats() async {
    final logs = await databaseService.getPrayerLogs();
    
    return {
      'totalPrayers': logs.length,
      'fajr': logs.where((l) => l.prayerName == 'Fajr').length,
      'dhuhr': logs.where((l) => l.prayerName == 'Dhuhr').length,
      'asr': logs.where((l) => l.prayerName == 'Asr').length,
      'maghrib': logs.where((l) => l.prayerName == 'Maghrib').length,
      'isha': logs.where((l) => l.prayerName == 'Isha').length,
    };
  }

  // Feature 2: Get weekly summary
  Future<Map<String, dynamic>> getWeeklySummary() async {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(Duration(days: 6));

    final logs = await databaseService.getPrayerLogs(
      startDate: startOfWeek,
      endDate: endOfWeek,
    );

    final weeklyData = <String, int>{};
    for (int i = 0; i < 7; i++) {
      final date = startOfWeek.add(Duration(days: i));
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      weeklyData[dateStr] = logs
          .where((l) =>
              DateFormat('yyyy-MM-dd').format(l.dateLogged) == dateStr)
          .length;
    }

    return {
      'weeklyData': weeklyData,
      'totalThisWeek': logs.length,
      'averagePerDay': logs.length / 7,
    };
  }

  // Feature 2: Get monthly summary
  Future<Map<String, dynamic>> getMonthlySummary([int? month, int? year]) async {
    final now = DateTime.now();
    final targetMonth = month ?? now.month;
    final targetYear = year ?? now.year;

    final startOfMonth = DateTime(targetYear, targetMonth, 1);
    final endOfMonth = DateTime(targetYear, targetMonth + 1, 0);

    final logs = await databaseService.getPrayerLogs(
      startDate: startOfMonth,
      endDate: endOfMonth,
    );

    final daysInMonth = endOfMonth.day;
    final dailyData = <String, int>{};
    
    for (int i = 1; i <= daysInMonth; i++) {
      final date = DateTime(targetYear, targetMonth, i);
      final dateStr = DateFormat('yyyy-MM-dd').format(date);
      dailyData[dateStr] = logs
          .where((l) =>
              DateFormat('yyyy-MM-dd').format(l.dateLogged) == dateStr)
          .length;
    }

    return {
      'dailyData': dailyData,
      'totalThisMonth': logs.length,
      'averagePerDay': logs.length / daysInMonth,
      'month': DateFormat('MMMM yyyy').format(startOfMonth),
    };
  }

  // Feature 2: Get per-prayer progress
  Future<Map<String, dynamic>> getPrayerProgress(String prayerName) async {
    final logs = await databaseService.getPrayerLogs(prayerName: prayerName);
    final counts = await databaseService.getPrayerCounts();
    
    final totalPrayers = counts.firstWhere(
      (c) => c.prayerName == prayerName,
      orElse: () => PrayerCount(prayerName: prayerName, count: 0),
    ).count;

    return {
      'prayerName': prayerName,
      'completed': logs.length,
      'remaining': totalPrayers,
      'percentage': totalPrayers > 0 ? (logs.length / totalPrayers * 100) : 0,
    };
  }

  // Feature 7: Get smart insights
  Future<Map<String, dynamic>> getSmartInsights() async {
    final logs = await databaseService.getPrayerLogs();
    
    if (logs.isEmpty) {
      return {'message': 'No prayer data yet. Start logging to see insights!'};
    }

    // Find best prayer completion time
    final timeGroups = <String, int>{};
    for (final log in logs) {
      timeGroups[log.timeLogged] = (timeGroups[log.timeLogged] ?? 0) + 1;
    }
    final bestTime = timeGroups.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Find most completed prayer
    final prayerGroups = <String, int>{};
    for (final log in logs) {
      prayerGroups[log.prayerName] =
          (prayerGroups[log.prayerName] ?? 0) + 1;
    }
    final mostCompleted = prayerGroups.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    // Find day with most prayers
    final dayGroups = <String, int>{};
    for (final log in logs) {
      final dayName = DateFormat('EEEE').format(log.dateLogged);
      dayGroups[dayName] = (dayGroups[dayName] ?? 0) + 1;
    }
    final bestDay = dayGroups.entries
        .reduce((a, b) => a.value > b.value ? a : b)
        .key;

    return {
      'bestTime': bestTime,
      'bestTimeInsight':
          'You usually complete prayers around $bestTime',
      'mostCompleted': mostCompleted,
      'mostCompletedInsight':
          'You\'ve completed $mostCompleted the most',
      'bestDay': bestDay,
      'bestDayInsight': 'You complete more prayers on $bestDay',
      'totalLogged': logs.length,
      'daysActive': _getActiveDays(logs),
    };
  }

  int _getActiveDays(List<PrayerLog> logs) {
    final uniqueDates = logs
        .map((l) => DateFormat('yyyy-MM-dd').format(l.dateLogged))
        .toSet();
    return uniqueDates.length;
  }

  // Feature 7: Completion rate
  Future<double> getCompletionRate() async {
    final logs = await databaseService.getPrayerLogs();
    final counts = await databaseService.getPrayerCounts();
    
    final totalRemaining =
        counts.fold<int>(0, (sum, c) => sum + c.count);
    final totalCompleted = logs.length;
    final total = totalCompleted + totalRemaining;

    return total > 0 ? (totalCompleted / total * 100) : 0;
  }

  // Feature 2: Get comparison data
  Future<Map<String, dynamic>> getComparisonData() async {
    final counts = await databaseService.getPrayerCounts();
    final logs = await databaseService.getPrayerLogs();

    final totalRemaining =
        counts.fold<int>(0, (sum, c) => sum + c.count);
    final totalCompleted = logs.length;

    final prayerComparison = <String, Map<String, int>>{};
    for (final prayer in counts) {
      final completed = logs
          .where((l) => l.prayerName == prayer.prayerName)
          .length;
      prayerComparison[prayer.prayerName] = {
        'completed': completed,
        'remaining': prayer.count,
      };
    }

    return {
      'totalCompleted': totalCompleted,
      'totalRemaining': totalRemaining,
      'prayerComparison': prayerComparison,
    };
  }
}
