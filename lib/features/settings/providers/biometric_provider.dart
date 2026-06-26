import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _biometricEnabledKey = 'biometric_lock_enabled';

class BiometricLockNotifier extends Notifier<bool> {
  final _auth = LocalAuthentication();

  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(_biometricEnabledKey) ?? false;
  }

  Future<bool> canUseBiometrics() async {
    try {
      final supported = await _auth.isDeviceSupported();
      if (!supported) return false;
      return await _auth.canCheckBiometrics ||
          await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<void> setEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_biometricEnabledKey, enabled);
    state = enabled;
  }

  Future<bool> authenticate({String reason = 'Unlock MarksmanMate'}) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
        ),
      );
    } catch (_) {
      return false;
    }
  }
}

final biometricLockProvider =
    NotifierProvider<BiometricLockNotifier, bool>(BiometricLockNotifier.new);

final biometricAvailableProvider = FutureProvider<bool>((ref) async {
  return ref.read(biometricLockProvider.notifier).canUseBiometrics();
});
