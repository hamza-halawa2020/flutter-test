import 'package:flutter/material.dart';
import '../models/prayer_model.dart';
import '../services/achievement_service.dart';
import '../services/notification_service.dart';

class AchievementProvider with ChangeNotifier {
  final AchievementService _achievementService;
  final NotificationService _notificationService;

  List<Achievement> _achievements = [];
  UserStreak _currentStreak = UserStreak(
    currentStreak: 0,
    longestStreak: 0,
    lastCompletionDate: DateTime.now(),
  );
  List<Achievement> _newlyUnlockedAchievements = [];

  AchievementProvider(
    this._achievementService,
    this._notificationService,
  );

  // Getters
  List<Achievement> get achievements => _achievements;
  UserStreak get currentStreak => _currentStreak;
  List<Achievement> get newlyUnlockedAchievements => _newlyUnlockedAchievements;
  int get unlockedCount => _achievements.where((a) => a.unlocked).length;

  // Initialize achievements
  Future<void> initialize() async {
    _achievements = _achievementService.getDefaultAchievements();
    await checkAchievements();
  }

  // Feature 8: Check achievements
  Future<void> checkAchievements() async {
    final previousUnlocked = _achievements.where((a) => a.unlocked).toList();
    _currentStreak = await _achievementService.calculateStreak();
    _achievements = await _achievementService.checkAchievements(_achievements);

    // Get newly unlocked achievements
    final currentUnlocked = _achievements.where((a) => a.unlocked).toList();
    _newlyUnlockedAchievements = currentUnlocked
        .where(
          (a) => !previousUnlocked.any((p) => p.id == a.id),
        )
        .toList();

    // Show notifications for newly unlocked achievements
    for (final achievement in _newlyUnlockedAchievements) {
      await _notificationService.showAchievementNotification(
        achievement.title,
        achievement.description,
      );
    }

    notifyListeners();
  }

  // Feature 8: Get badge icon
  String getBadgeIcon(String achievementId) {
    return _achievementService.getBadgeIcon(achievementId);
  }

  // Feature 8: Get achievement progress
  Future<double> getAchievementProgress(Achievement achievement) async {
    return await _achievementService.getAchievementProgress(achievement);
  }

  // Clear newly unlocked list after showing
  void clearNewlyUnlockedAchievements() {
    _newlyUnlockedAchievements.clear();
    notifyListeners();
  }
}
