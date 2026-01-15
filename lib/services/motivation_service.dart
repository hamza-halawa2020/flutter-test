import 'package:intl/intl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/prayer_model.dart';

class MotivationService {
  final _secureStorage = const FlutterSecureStorage();

  // Feature 3: Default Islamic motivation messages
  List<MotivationMessage> getDefaultMessages() {
    return [
      MotivationMessage(
        text: 'Every step towards prayer is a step closer to Allah\'s mercy.',
        source: 'Islamic Wisdom',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'The best deeds are those done consistently, even if small.',
        source: 'Prophet Muhammad (PBUH)',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Your prayers are your connection to the Divine.',
        source: 'Islamic Teaching',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Logging a missed prayer is an act of seeking forgiveness.',
        source: 'Islamic Guidance',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'With every prayer, you strengthen your relationship with Allah.',
        source: 'Islamic Wisdom',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Never lose hope; Allah\'s forgiveness is infinite.',
        source: 'Quranic Teaching',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Consistency in prayer is the foundation of spiritual growth.',
        source: 'Islamic Teaching',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Your intention matters; pray with sincere hearts.',
        source: 'Islamic Hadith',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Each prayer is an opportunity to renew your faith.',
        source: 'Islamic Wisdom',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Strive to fulfill your prayers; they are your protection.',
        source: 'Quranic Reference',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Remember, Allah never burdens a soul beyond its capacity.',
        source: 'Quranic Teaching',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Your effort in tracking prayers shows your commitment.',
        source: 'Islamic Encouragement',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Prayer is not just about obedience; it\'s about peace.',
        source: 'Islamic Wisdom',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Seek forgiveness, not despair, for missed prayers.',
        source: 'Islamic Guidance',
        dateAdded: DateTime.now(),
      ),
      MotivationMessage(
        text: 'Your journey to consistency begins with a single prayer.',
        source: 'Motivational Quote',
        dateAdded: DateTime.now(),
      ),
    ];
  }

  // Feature 3: Get daily motivation message
  Future<MotivationMessage?> getDailyMotivation() async {
    try {
      final lastMessageDate = await _secureStorage.read(key: 'last_motivation_date');
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      // If no message shown today, get a new one
      if (lastMessageDate != today) {
        final messages = getDefaultMessages();
        final randomMessage = messages[DateTime.now().microsecond % messages.length];

        await _secureStorage.write(key: 'last_motivation_date', value: today);
        await _secureStorage.write(
          key: 'current_motivation',
          value: jsonEncode(randomMessage.toJson()),
        );

        return randomMessage;
      }

      // Return today's cached message
      final cached = await _secureStorage.read(key: 'current_motivation');
      if (cached != null) {
        final decoded = jsonDecode(cached);
        return MotivationMessage.fromJson(decoded);
      }

      return null;
    } catch (e) {
      print('Error getting daily motivation: $e');
      return null;
    }
  }

  // Feature 3: Get all motivation messages
  Future<List<MotivationMessage>> getAllMessages() async {
    try {
      final json = await _secureStorage.read(key: 'all_motivation_messages');
      if (json != null) {
        final decoded = jsonDecode(json) as List;
        return decoded
            .map((m) => MotivationMessage.fromJson(m as Map<String, dynamic>))
            .toList();
      }
      return getDefaultMessages();
    } catch (e) {
      print('Error getting all messages: $e');
      return getDefaultMessages();
    }
  }

  // Feature 3: Add custom motivation message
  Future<bool> addCustomMessage(String text, String source) async {
    try {
      final newMessage = MotivationMessage(
        text: text,
        source: source,
        dateAdded: DateTime.now(),
      );

      final messages = await getAllMessages();
      messages.add(newMessage);

      final json =
          jsonEncode(messages.map((m) => m.toJson()).toList());
      await _secureStorage.write(key: 'all_motivation_messages', value: json);

      return true;
    } catch (e) {
      print('Error adding custom message: $e');
      return false;
    }
  }

  // Feature 3: Enable/Disable motivation messages
  Future<bool> setMotivationEnabled(bool enabled) async {
    try {
      await _secureStorage.write(
        key: 'motivation_enabled',
        value: enabled ? 'true' : 'false',
      );
      return true;
    } catch (e) {
      print('Error setting motivation: $e');
      return false;
    }
  }

  // Feature 3: Check if motivation is enabled
  Future<bool> isMotivationEnabled() async {
    try {
      final value = await _secureStorage.read(key: 'motivation_enabled');
      return value == 'true' || value == null; // Default true
    } catch (e) {
      return true;
    }
  }

  // Feature 3: Get random motivation message (for notifications)
  Future<MotivationMessage> getRandomMotivation() async {
    try {
      final messages = await getAllMessages();
      if (messages.isEmpty) {
        return MotivationMessage(
          text: 'Keep pushing forward in your spiritual journey!',
          source: 'App Encouragement',
          dateAdded: DateTime.now(),
        );
      }
      return messages[DateTime.now().microsecond % messages.length];
    } catch (e) {
      return MotivationMessage(
        text: 'You\'re doing great! Keep praying.',
        source: 'App Encouragement',
        dateAdded: DateTime.now(),
      );
    }
  }

  // Feature 3: Save motivation settings
  Future<bool> saveMotivationSettings(MotivationSettings settings) async {
    try {
      await _secureStorage.write(
        key: 'motivation_settings',
        value: jsonEncode(settings.toJson()),
      );
      return true;
    } catch (e) {
      print('Error saving motivation settings: $e');
      return false;
    }
  }

  // Feature 3: Load motivation settings
  Future<MotivationSettings> loadMotivationSettings() async {
    try {
      final json = await _secureStorage.read(key: 'motivation_settings');
      if (json != null) {
        final decoded = jsonDecode(json);
        return MotivationSettings.fromJson(decoded);
      }
      return MotivationSettings(
        enabled: true,
        lastMessageDate: DateTime.now(),
      );
    } catch (e) {
      return MotivationSettings(
        enabled: true,
        lastMessageDate: DateTime.now(),
      );
    }
  }
}
