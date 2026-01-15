import 'package:intl/intl.dart';
import '../models/prayer_model.dart';
import 'database_service.dart';

class AchievementService {
  final DatabaseService databaseService;

  AchievementService(this.databaseService);

  // Feature 8 & 9: Initialize achievements
  List<Achievement> getDefaultAchievements() {
    return [
      Achievement(
        id: 'first_prayer',
        title: 'First Step',
        description: 'Log your first prayer',
        targetValue: 1,
      ),
      Achievement(
        id: 'seven_days',
        title: 'One Week Wonder',
        description: 'Maintain a 7-day streak',
        targetValue: 7,
      ),
      Achievement(
        id: 'thirty_days',
        title: 'Thirty Day Challenge',
        description: 'Maintain a 30-day streak',
        targetValue: 30,
      ),
      Achievement(
        id: 'hundred_prayers',
        title: 'Century',
        description: 'Complete 100 prayers',
        targetValue: 100,
      ),
      Achievement(
        id: 'fajr_master',
        title: 'Early Riser',
        description: 'Complete 50 Fajr prayers',
        targetValue: 50,
      ),
      Achievement(
        id: 'consistent_day',
        title: 'Perfect Day',
        description: 'Complete all 5 prayers in a single day',
        targetValue: 5,
      ),
      Achievement(
        id: 'thousand_prayers',
        title: 'Spiritual Warrior',
        description: 'Complete 1000 prayers',
        targetValue: 1000,
      ),
      Achievement(
        id: 'week_perfect',
        title: 'Weekly Champion',
        description: 'Complete 35 prayers in a week',
        targetValue: 35,
      ),
    ];
  }

  // Feature 8: Calculate current streak
  Future<UserStreak> calculateStreak() async {
    final logs = await databaseService.getPrayerLogs();
    
    if (logs.isEmpty) {
      return UserStreak(
        currentStreak: 0,
        longestStreak: 0,
        lastCompletionDate: DateTime.now(),
      );
    }

    // Get unique dates sorted in descending order
    final uniqueDates = logs
        .map((l) => DateFormat('yyyy-MM-dd').format(l.dateLogged))
        .toSet()
        .toList()
        .map((dateStr) => DateTime.parse(dateStr))
        .toList()
        ..sort((a, b) => b.compareTo(a));

    if (uniqueDates.isEmpty) {
      return UserStreak(
        currentStreak: 0,
        longestStreak: 0,
        lastCompletionDate: DateTime.now(),
      );
    }

    // Calculate current streak
    int currentStreak = 0;
    DateTime? lastDate;
    
    for (final date in uniqueDates) {
      if (lastDate == null) {
        // First date - check if it's today or yesterday
        final now = DateTime.now();
        final yesterday = now.subtract(Duration(days: 1));
        
        if (_isSameDay(date, now) || _isSameDay(date, yesterday)) {
          currentStreak = 1;
          lastDate = date;
        } else {
          break;
        }
      } else {
        // Check if date is exactly one day before last date
        final expectedDate = lastDate.subtract(Duration(days: 1));
        if (_isSameDay(date, expectedDate)) {
          currentStreak++;
          lastDate = date;
        } else {
          break;
        }
      }
    }

    // Calculate longest streak
    int longestStreak = 1;
    int tempStreak = 1;
    
    for (int i = 0; i < uniqueDates.length - 1; i++) {
      final diff =
          uniqueDates[i].difference(uniqueDates[i + 1]).inDays;
      if (diff == 1) {
        tempStreak++;
      } else {
        longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;
        tempStreak = 1;
      }
    }
    longestStreak = longestStreak > tempStreak ? longestStreak : tempStreak;

    return UserStreak(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      lastCompletionDate: uniqueDates.first,
    );
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  // Feature 9: Check and unlock achievements
  Future<List<Achievement>> checkAchievements(
    List<Achievement> achievements,
  ) async {
    final logs = await databaseService.getPrayerLogs();
    final counts = await databaseService.getPrayerCounts();
    final streak = await calculateStreak();
    final dailyStats = await databaseService.getDailyStatistics(DateTime.now());

    final updatedAchievements = achievements.map((achievement) {
      if (achievement.unlocked) return achievement;

      bool shouldUnlock = false;
      switch (achievement.id) {
        case 'first_prayer':
          shouldUnlock = logs.isNotEmpty;
          break;
        case 'seven_days':
          shouldUnlock = streak.currentStreak >= 7;
          break;
        case 'thirty_days':
          shouldUnlock = streak.currentStreak >= 30;
          break;
        case 'hundred_prayers':
          shouldUnlock = logs.length >= 100;
          break;
        case 'fajr_master':
          final fajrCount = logs
              .where((l) => l.prayerName == 'Fajr')
              .length;
          shouldUnlock = fajrCount >= 50;
          break;
        case 'consistent_day':
          shouldUnlock = dailyStats.totalCount >= 5;
          break;
        case 'thousand_prayers':
          shouldUnlock = logs.length >= 1000;
          break;
        case 'week_perfect':
          shouldUnlock = dailyStats.totalCount >= 35;
          break;
      }

      if (shouldUnlock && !achievement.unlocked) {
        return Achievement(
          id: achievement.id,
          title: achievement.title,
          description: achievement.description,
          unlocked: true,
          unlockedDate: DateTime.now(),
          targetValue: achievement.targetValue,
        );
      }
      return achievement;
    }).toList();

    return updatedAchievements;
  }

  // Feature 9: Get badge icon based on achievement
  String getBadgeIcon(String achievementId) {
    const badgeMap = {
      'first_prayer': '🚀',
      'seven_days': '📅',
      'thirty_days': '🔥',
      'hundred_prayers': '💯',
      'fajr_master': '🌅',
      'consistent_day': '✨',
      'thousand_prayers': '🏆',
      'week_perfect': '⭐',
    };
    return badgeMap[achievementId] ?? '🎯';
  }

  // Get progress percentage for achievement
  Future<double> getAchievementProgress(Achievement achievement) async {
    final logs = await databaseService.getPrayerLogs();
    final streak = await calculateStreak();

    switch (achievement.id) {
      case 'hundred_prayers':
        return (logs.length / 100.0).clamp(0.0, 1.0);
      case 'fajr_master':
        final fajrCount =
            logs.where((l) => l.prayerName == 'Fajr').length;
        return (fajrCount / 50.0).clamp(0.0, 1.0);
      case 'seven_days':
        return (streak.currentStreak / 7.0).clamp(0.0, 1.0);
      case 'thirty_days':
        return (streak.currentStreak / 30.0).clamp(0.0, 1.0);
      case 'thousand_prayers':
        return (logs.length / 1000.0).clamp(0.0, 1.0);
      default:
        return achievement.unlocked ? 1.0 : 0.0;
    }
  }
}
