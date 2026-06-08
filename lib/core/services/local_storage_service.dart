import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  return LocalStorageService();
});

class LocalStorageService {
  static const String _keyFirstLaunch = 'is_first_launch';
  static const String _keySelectedRole = 'selected_role';
  static const String _keyDeviceId = 'local_device_id';
  static const String _keyMultiDeviceLogout = 'multi_device_logout';

  /// Check if this is the first time the app is launched
  Future<bool> isFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyFirstLaunch) ?? true;
  }

  /// Set that the onboarding has been completed
  Future<void> setOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, false);
  }

  /// Reset onboarding status (useful for testing)
  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyFirstLaunch, true);
  }

  /// Get unique local device ID, generating it if it doesn't exist.
  Future<String> getLocalDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_keyDeviceId);
    if (deviceId == null) {
      deviceId = const Uuid().v4();
      await prefs.setString(_keyDeviceId, deviceId);
    }
    return deviceId;
  }

  /// Get selected user role
  Future<String?> getSelectedRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySelectedRole);
  }

  /// Set selected user role
  Future<void> setSelectedRole(String roleName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySelectedRole, roleName);
  }

  /// Set multi-device logout flag
  Future<void> setMultiDeviceLogout(bool val) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyMultiDeviceLogout, val);
  }

  /// Get and clear the multi-device logout flag
  Future<bool> checkAndClearMultiDeviceLogout() async {
    final prefs = await SharedPreferences.getInstance();
    final val = prefs.getBool(_keyMultiDeviceLogout) ?? false;
    if (val) {
      await prefs.setBool(_keyMultiDeviceLogout, false);
    }
    return val;
  }
}
