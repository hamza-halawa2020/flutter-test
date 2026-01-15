import 'package:flutter/material.dart';
import '../models/prayer_model.dart';
import '../services/motivation_service.dart';

class MotivationProvider with ChangeNotifier {
  final MotivationService _motivationService;

  MotivationMessage? _currentDailyMessage;
  bool _motivationEnabled = true;
  List<MotivationMessage> _allMessages = [];
  MotivationSettings _settings = MotivationSettings(
    enabled: true,
    lastMessageDate: DateTime.now(),
  );

  MotivationProvider(this._motivationService);

  // Getters
  MotivationMessage? get currentDailyMessage => _currentDailyMessage;
  bool get motivationEnabled => _motivationEnabled;
  List<MotivationMessage> get allMessages => _allMessages;
  MotivationSettings get settings => _settings;

  // Feature 3: Initialize motivation
  Future<void> initialize() async {
    _motivationEnabled = await _motivationService.isMotivationEnabled();
    _settings = await _motivationService.loadMotivationSettings();
    await getDailyMotivation();
    _allMessages = await _motivationService.getAllMessages();
    notifyListeners();
  }

  // Feature 3: Get daily motivation
  Future<void> getDailyMotivation() async {
    _currentDailyMessage = await _motivationService.getDailyMotivation();
    notifyListeners();
  }

  // Feature 3: Add custom message
  Future<bool> addCustomMessage(String text, String source) async {
    final result = await _motivationService.addCustomMessage(text, source);
    if (result) {
      _allMessages = await _motivationService.getAllMessages();
      notifyListeners();
    }
    return result;
  }

  // Feature 3: Set motivation enabled
  Future<bool> setMotivationEnabled(bool enabled) async {
    final result = await _motivationService.setMotivationEnabled(enabled);
    if (result) {
      _motivationEnabled = enabled;
      notifyListeners();
    }
    return result;
  }

  // Feature 3: Get random motivation
  Future<MotivationMessage> getRandomMotivation() async {
    return await _motivationService.getRandomMotivation();
  }

  // Feature 3: Refresh messages
  Future<void> refreshMessages() async {
    _allMessages = await _motivationService.getAllMessages();
    notifyListeners();
  }
}
