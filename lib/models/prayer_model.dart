import 'package:json_annotation/json_annotation.dart';

part 'prayer_model.g.dart';

@JsonSerializable()
class PrayerCount {
  String prayerName;
  int count;
  
  PrayerCount({
    required this.prayerName,
    required this.count,
  });

  factory PrayerCount.fromJson(Map<String, dynamic> json) =>
      _$PrayerCountFromJson(json);
      
  Map<String, dynamic> toJson() => _$PrayerCountToJson(this);
  
  PrayerCount copyWith({
    String? prayerName,
    int? count,
  }) {
    return PrayerCount(
      prayerName: prayerName ?? this.prayerName,
      count: count ?? this.count,
    );
  }
}

@JsonSerializable()
class PrayerLog {
  int? id;
  String prayerName;
  DateTime dateLogged;
  String timeLogged;
  bool? isEdited; // Feature 9: Track if log was edited
  
  PrayerLog({
    this.id,
    required this.prayerName,
    required this.dateLogged,
    required this.timeLogged,
    this.isEdited = false,
  });

  factory PrayerLog.fromJson(Map<String, dynamic> json) =>
      _$PrayerLogFromJson(json);
      
  Map<String, dynamic> toJson() => _$PrayerLogToJson(this);
  
  PrayerLog copyWith({
    int? id,
    String? prayerName,
    DateTime? dateLogged,
    String? timeLogged,
    bool? isEdited,
  }) {
    return PrayerLog(
      id: id ?? this.id,
      prayerName: prayerName ?? this.prayerName,
      dateLogged: dateLogged ?? this.dateLogged,
      timeLogged: timeLogged ?? this.timeLogged,
      isEdited: isEdited ?? this.isEdited,
    );
  }
}

@JsonSerializable()
class DailyStatistics {
  DateTime date;
  int fajrCount;
  int dhuhrCount;
  int asrCount;
  int maghribCount;
  int ishaCount;
  
  DailyStatistics({
    required this.date,
    this.fajrCount = 0,
    this.dhuhrCount = 0,
    this.asrCount = 0,
    this.maghribCount = 0,
    this.ishaCount = 0,
  });

  int get totalCount => fajrCount + dhuhrCount + asrCount + maghribCount + ishaCount;

  factory DailyStatistics.fromJson(Map<String, dynamic> json) =>
      _$DailyStatisticsFromJson(json);
      
  Map<String, dynamic> toJson() => _$DailyStatisticsToJson(this);
  
  DailyStatistics copyWith({
    DateTime? date,
    int? fajrCount,
    int? dhuhrCount,
    int? asrCount,
    int? maghribCount,
    int? ishaCount,
  }) {
    return DailyStatistics(
      date: date ?? this.date,
      fajrCount: fajrCount ?? this.fajrCount,
      dhuhrCount: dhuhrCount ?? this.dhuhrCount,
      asrCount: asrCount ?? this.asrCount,
      maghribCount: maghribCount ?? this.maghribCount,
      ishaCount: ishaCount ?? this.ishaCount,
    );
  }
}

// Feature 8 & 9: Streak and Achievement tracking
@JsonSerializable()
class UserStreak {
  int currentStreak; // Days in a row
  int longestStreak;
  DateTime lastCompletionDate;
  
  UserStreak({
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastCompletionDate,
  });
  
  factory UserStreak.fromJson(Map<String, dynamic> json) =>
      _$UserStreakFromJson(json);
  Map<String, dynamic> toJson() => _$UserStreakToJson(this);
}

@JsonSerializable()
class Achievement {
  String id;
  String title;
  String description;
  bool unlocked;
  DateTime? unlockedDate;
  int? targetValue; // e.g., 7 days, 30 days, 100 prayers
  
  Achievement({
    required this.id,
    required this.title,
    required this.description,
    this.unlocked = false,
    this.unlockedDate,
    this.targetValue,
  });
  
  factory Achievement.fromJson(Map<String, dynamic> json) =>
      _$AchievementFromJson(json);
  Map<String, dynamic> toJson() => _$AchievementToJson(this);
}

// Feature 1: Reminder settings
@JsonSerializable()
class ReminderSettings {
  bool dailyReminders;
  String? reminderTime; // HH:mm format
  bool weeklyMotivation;
  String? weeklyMotivationDay; // e.g., "Friday"
  
  ReminderSettings({
    this.dailyReminders = true,
    this.reminderTime = '08:00',
    this.weeklyMotivation = true,
    this.weeklyMotivationDay = 'Friday',
  });
  
  factory ReminderSettings.fromJson(Map<String, dynamic> json) =>
      _$ReminderSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$ReminderSettingsToJson(this);
}

// Feature 3: Motivational messages
@JsonSerializable()
class MotivationMessage {
  String text;
  String? source;
  DateTime dateAdded;
  
  MotivationMessage({
    required this.text,
    this.source,
    required this.dateAdded,
  });
  
  factory MotivationMessage.fromJson(Map<String, dynamic> json) =>
      _$MotivationMessageFromJson(json);
  Map<String, dynamic> toJson() => _$MotivationMessageToJson(this);
}

// Feature 5: Security settings
@JsonSerializable()
class SecuritySettings {
  bool pinEnabled;
  String? pinHash;
  bool biometricEnabled;
  bool hideStatsOnSwitcher;
  
  SecuritySettings({
    this.pinEnabled = false,
    this.pinHash,
    this.biometricEnabled = false,
    this.hideStatsOnSwitcher = true,
  });
  
  factory SecuritySettings.fromJson(Map<String, dynamic> json) =>
      _$SecuritySettingsFromJson(json);
  Map<String, dynamic> toJson() => _$SecuritySettingsToJson(this);
}

// Feature 6: Accessibility settings
@JsonSerializable()
class AccessibilitySettings {
  double textScale; // 1.0 = normal, 1.5 = large, 2.0 = extra large
  bool highContrast;
  bool oneHandMode;
  bool hapticFeedback;
  
  AccessibilitySettings({
    this.textScale = 1.0,
    this.highContrast = false,
    this.oneHandMode = false,
    this.hapticFeedback = true,
  });
  
  factory AccessibilitySettings.fromJson(Map<String, dynamic> json) =>
      _$AccessibilitySettingsFromJson(json);
  Map<String, dynamic> toJson() => _$AccessibilitySettingsToJson(this);
}

// Feature 3: Motivation settings
@JsonSerializable()
class MotivationSettings {
  bool enabled;
  String? lastMessageDate;
  
  MotivationSettings({
    this.enabled = true,
    this.lastMessageDate,
  });
  
  factory MotivationSettings.fromJson(Map<String, dynamic> json) =>
      _$MotivationSettingsFromJson(json);
  Map<String, dynamic> toJson() => _$MotivationSettingsToJson(this);
}

// Feature 10: Custom theme
@JsonSerializable()
class CustomTheme {
  String name;
  int primaryColor;
  int accentColor;
  bool isDark;
  
  CustomTheme({
    required this.name,
    required this.primaryColor,
    required this.accentColor,
    this.isDark = false,
  });
  
  factory CustomTheme.fromJson(Map<String, dynamic> json) =>
      _$CustomThemeFromJson(json);
  Map<String, dynamic> toJson() => _$CustomThemeToJson(this);
}

const List<String> prayerNames = [
  'Fajr',
  'Dhuhr',
  'Asr',
  'Maghrib',
  'Isha',
];
];
