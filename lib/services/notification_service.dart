import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import '../models/prayer_model.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  Future<void> init() async {
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('app_icon');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Handle notification tap
      },
    );

    // Request permissions (iOS 10+)
    await _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  // Feature 1: Schedule daily reminder
  Future<void> scheduleDailyReminder({
    required String time, // HH:mm format
    required String message,
  }) async {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        1, // Notification ID
        'Prayer Reminder',
        message,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_reminder_channel',
            'Prayer Reminders',
            channelDescription: 'Daily prayer reminders',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAndAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (e) {
      print('Error scheduling reminder: $e');
    }
  }

  // Feature 1: Schedule weekly motivation
  Future<void> scheduleWeeklyMotivation({
    required String dayOfWeek, // Monday, Tuesday, etc.
    required String time,
    required String motivationMessage,
  }) async {
    try {
      final parts = time.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      await flutterLocalNotificationsPlugin.zonedSchedule(
        2, // Notification ID for motivation
        'Weekly Motivation',
        motivationMessage,
        _nextInstanceOfTime(hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'motivation_channel',
            'Motivation Messages',
            channelDescription: 'Weekly motivational messages',
            importance: Importance.default_,
            priority: Priority.default_,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAndAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    } catch (e) {
      print('Error scheduling weekly motivation: $e');
    }
  }

  // Instant notification when prayer completed
  Future<void> showPrayerCompletedNotification(String prayerName) async {
    try {
      await flutterLocalNotificationsPlugin.show(
        3,
        'Prayer Completed!',
        '$prayerName recorded successfully ✓',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'prayer_completion_channel',
            'Prayer Completion',
            channelDescription: 'Notifications when prayers are logged',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      print('Error showing notification: $e');
    }
  }

  // Achievement unlocked notification
  Future<void> showAchievementNotification(String title, String description) async {
    try {
      await flutterLocalNotificationsPlugin.show(
        4,
        '🏆 $title',
        description,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'achievement_channel',
            'Achievements',
            channelDescription: 'Achievement notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
      );
    } catch (e) {
      print('Error showing achievement notification: $e');
    }
  }

  // Cancel all notifications
  Future<void> cancelAll() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancel(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Helper to calculate next instance of time
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
