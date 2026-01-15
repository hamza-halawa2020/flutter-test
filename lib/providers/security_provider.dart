import 'package:flutter/material.dart';
import '../models/prayer_model.dart';
import '../services/security_service.dart';

class SecurityProvider with ChangeNotifier {
  final SecurityService _securityService;

  bool _isPINEnabled = false;
  bool _isBiometricEnabled = false;
  bool _isBiometricAvailable = false;
  bool _isAuthenticated = false;
  SecuritySettings _securitySettings = SecuritySettings(
    pinEnabled: false,
    pinHash: '',
    biometricEnabled: false,
    hideStatsOnSwitcher: false,
  );

  SecurityProvider(this._securityService);

  // Getters
  bool get isPINEnabled => _isPINEnabled;
  bool get isBiometricEnabled => _isBiometricEnabled;
  bool get isBiometricAvailable => _isBiometricAvailable;
  bool get isAuthenticated => _isAuthenticated;
  SecuritySettings get securitySettings => _securitySettings;

  // Feature 5: Initialize security
  Future<void> initialize() async {
    _isPINEnabled = await _securityService.isPINEnabled();
    _isBiometricEnabled = await _securityService.isBiometricEnabled();
    _isBiometricAvailable = await _securityService.isBiometricAvailable();
    _securitySettings = await _securityService.loadSecuritySettings();
    notifyListeners();
  }

  // Feature 5: Set PIN
  Future<bool> setPIN(String pin) async {
    final result = await _securityService.setPIN(pin);
    if (result) {
      _isPINEnabled = true;
      await _loadSecuritySettings();
      notifyListeners();
    }
    return result;
  }

  // Feature 5: Verify PIN
  Future<bool> verifyPIN(String pin) async {
    return await _securityService.verifyPIN(pin);
  }

  // Feature 5: Disable PIN
  Future<bool> disablePIN() async {
    final result = await _securityService.disablePIN();
    if (result) {
      _isPINEnabled = false;
      await _loadSecuritySettings();
      notifyListeners();
    }
    return result;
  }

  // Feature 5: Enable biometric
  Future<bool> enableBiometric() async {
    final result = await _securityService.enableBiometric();
    if (result) {
      _isBiometricEnabled = true;
      await _loadSecuritySettings();
      notifyListeners();
    }
    return result;
  }

  // Feature 5: Disable biometric
  Future<bool> disableBiometric() async {
    final result = await _securityService.disableBiometric();
    if (result) {
      _isBiometricEnabled = false;
      await _loadSecuritySettings();
      notifyListeners();
    }
    return result;
  }

  // Feature 5: Authenticate
  Future<bool> authenticate({
    required bool usePIN,
    String? pin,
  }) async {
    final result = await _securityService.authenticate(
      usePIN: usePIN,
      pin: pin,
    );
    _isAuthenticated = result;
    notifyListeners();
    return result;
  }

  // Feature 5: Load security settings
  Future<void> _loadSecuritySettings() async {
    _securitySettings = await _securityService.loadSecuritySettings();
    notifyListeners();
  }

  // Feature 5: Update hideStatsOnSwitcher
  Future<bool> setHideStatsOnSwitcher(bool hide) async {
    _securitySettings = SecuritySettings(
      pinEnabled: _securitySettings.pinEnabled,
      pinHash: _securitySettings.pinHash,
      biometricEnabled: _securitySettings.biometricEnabled,
      hideStatsOnSwitcher: hide,
    );
    final result = await _securityService.saveSecuritySettings(_securitySettings);
    if (result) {
      notifyListeners();
    }
    return result;
  }
}
