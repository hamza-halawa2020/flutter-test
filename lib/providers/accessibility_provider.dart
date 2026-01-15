import 'package:flutter/material.dart';
import '../models/prayer_model.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';

class AccessibilityProvider with ChangeNotifier {
  final _secureStorage = const FlutterSecureStorage();

  AccessibilitySettings _settings = AccessibilitySettings(
    textScale: 1.0,
    highContrast: false,
    oneHandMode: false,
    hapticFeedback: true,
  );

  AccessibilityProvider();

  // Getters
  AccessibilitySettings get settings => _settings;
  double get textScale => _settings.textScale;
  bool get highContrast => _settings.highContrast;
  bool get oneHandMode => _settings.oneHandMode;
  bool get hapticFeedback => _settings.hapticFeedback;

  // Feature 6: Initialize accessibility
  Future<void> initialize() async {
    await _loadSettings();
  }

  // Feature 6: Set text scale
  Future<bool> setTextScale(double scale) async {
    _settings = AccessibilitySettings(
      textScale: scale.clamp(0.8, 1.5),
      highContrast: _settings.highContrast,
      oneHandMode: _settings.oneHandMode,
      hapticFeedback: _settings.hapticFeedback,
    );
    await _saveSettings();
    notifyListeners();
    return true;
  }

  // Feature 6: Toggle high contrast
  Future<bool> setHighContrast(bool enabled) async {
    _settings = AccessibilitySettings(
      textScale: _settings.textScale,
      highContrast: enabled,
      oneHandMode: _settings.oneHandMode,
      hapticFeedback: _settings.hapticFeedback,
    );
    await _saveSettings();
    notifyListeners();
    return true;
  }

  // Feature 6: Toggle one-hand mode
  Future<bool> setOneHandMode(bool enabled) async {
    _settings = AccessibilitySettings(
      textScale: _settings.textScale,
      highContrast: _settings.highContrast,
      oneHandMode: enabled,
      hapticFeedback: _settings.hapticFeedback,
    );
    await _saveSettings();
    notifyListeners();
    return true;
  }

  // Feature 6: Toggle haptic feedback
  Future<bool> setHapticFeedback(bool enabled) async {
    _settings = AccessibilitySettings(
      textScale: _settings.textScale,
      highContrast: _settings.highContrast,
      oneHandMode: _settings.oneHandMode,
      hapticFeedback: enabled,
    );
    await _saveSettings();
    notifyListeners();
    return true;
  }

  // Feature 6: Save settings
  Future<bool> _saveSettings() async {
    try {
      await _secureStorage.write(
        key: 'accessibility_settings',
        value: jsonEncode(_settings.toJson()),
      );
      return true;
    } catch (e) {
      print('Error saving accessibility settings: $e');
      return false;
    }
  }

  // Feature 6: Load settings
  Future<void> _loadSettings() async {
    try {
      final json = await _secureStorage.read(key: 'accessibility_settings');
      if (json != null) {
        final decoded = jsonDecode(json);
        _settings = AccessibilitySettings.fromJson(decoded);
      }
    } catch (e) {
      print('Error loading accessibility settings: $e');
    }
    notifyListeners();
  }
}
