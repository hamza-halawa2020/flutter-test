import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'dart:convert';
import '../models/prayer_model.dart';

class SecurityService {
  final _secureStorage = const FlutterSecureStorage();
  late final LocalAuthentication _localAuth;

  SecurityService() {
    _localAuth = LocalAuthentication();
  }

  // Feature 5: Set PIN for data protection
  Future<bool> setPIN(String pin) async {
    try {
      final hashedPin = _hashPin(pin);
      await _secureStorage.write(key: 'pin_hash', value: hashedPin);
      await _secureStorage.write(key: 'pin_enabled', value: 'true');
      return true;
    } catch (e) {
      print('Error setting PIN: $e');
      return false;
    }
  }

  // Feature 5: Verify PIN
  Future<bool> verifyPIN(String pin) async {
    try {
      final storedHash = await _secureStorage.read(key: 'pin_hash');
      final inputHash = _hashPin(pin);
      return storedHash == inputHash;
    } catch (e) {
      print('Error verifying PIN: $e');
      return false;
    }
  }

  // Simple hash function for PIN (not cryptographically secure, for basic protection only)
  String _hashPin(String pin) {
    int hash = 0;
    if (pin.isEmpty) return hash.toString();
    for (int i = 0; i < pin.length; i++) {
      final char = pin.codeUnitAt(i);
      hash = ((hash << 5) - hash) + char;
      hash = hash & hash; // Convert to 32bit integer
    }
    return hash.toString();
  }

  // Feature 5: Check if PIN is enabled
  Future<bool> isPINEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: 'pin_enabled');
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  // Feature 5: Disable PIN protection
  Future<bool> disablePIN() async {
    try {
      await _secureStorage.delete(key: 'pin_hash');
      await _secureStorage.delete(key: 'pin_enabled');
      return true;
    } catch (e) {
      print('Error disabling PIN: $e');
      return false;
    }
  }

  // Feature 5: Enable biometric authentication
  Future<bool> enableBiometric() async {
    try {
      final isDeviceSupported = await _localAuth.canCheckBiometrics;
      final isDeviceSecure = await _localAuth.deviceSupportedAuthMethods();

      if (!isDeviceSupported) return false;

      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to enable biometric security',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        await _secureStorage.write(key: 'biometric_enabled', value: 'true');
        return true;
      }
      return false;
    } catch (e) {
      print('Error enabling biometric: $e');
      return false;
    }
  }

  // Feature 5: Check if biometric is available and enabled
  Future<bool> isBiometricEnabled() async {
    try {
      final enabled = await _secureStorage.read(key: 'biometric_enabled');
      return enabled == 'true';
    } catch (e) {
      return false;
    }
  }

  // Feature 5: Check if biometric is available on device
  Future<bool> isBiometricAvailable() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  // Feature 5: Authenticate with biometric
  Future<bool> authenticateWithBiometric() async {
    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Authenticate to access your prayer data',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );
      return authenticated;
    } catch (e) {
      print('Error authenticating with biometric: $e');
      return false;
    }
  }

  // Feature 5: Disable biometric
  Future<bool> disableBiometric() async {
    try {
      await _secureStorage.delete(key: 'biometric_enabled');
      return true;
    } catch (e) {
      print('Error disabling biometric: $e');
      return false;
    }
  }

  // Feature 5: Save security settings
  Future<bool> saveSecuritySettings(SecuritySettings settings) async {
    try {
      final json = settings.toJson();
      await _secureStorage.write(
        key: 'security_settings',
        value: jsonEncode(json),
      );
      return true;
    } catch (e) {
      print('Error saving security settings: $e');
      return false;
    }
  }

  // Feature 5: Load security settings
  Future<SecuritySettings> loadSecuritySettings() async {
    try {
      final json = await _secureStorage.read(key: 'security_settings');
      if (json != null) {
        final decoded = jsonDecode(json);
        return SecuritySettings.fromJson(decoded);
      }
      return SecuritySettings(
        pinEnabled: false,
        pinHash: '',
        biometricEnabled: false,
        hideStatsOnSwitcher: false,
      );
    } catch (e) {
      print('Error loading security settings: $e');
      return SecuritySettings(
        pinEnabled: false,
        pinHash: '',
        biometricEnabled: false,
        hideStatsOnSwitcher: false,
      );
    }
  }

  // Feature 5: Clear all security data
  Future<bool> clearAllSecurityData() async {
    try {
      await _secureStorage.deleteAll();
      return true;
    } catch (e) {
      print('Error clearing security data: $e');
      return false;
    }
  }

  // Feature 5: Authenticate user (PIN or Biometric)
  Future<bool> authenticate({
    required bool usePIN,
    String? pin,
  }) async {
    if (usePIN && pin != null) {
      return await verifyPIN(pin);
    } else {
      return await authenticateWithBiometric();
    }
  }

  // Feature 5: Get list of available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      print('Error getting available biometrics: $e');
      return [];
    }
  }
}
