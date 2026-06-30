import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../core/config/app_config.dart';

final googleSignInServiceProvider = Provider<GoogleSignInService>((ref) {
  return GoogleSignInService();
});

class GoogleSignInService {
  static var _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await GoogleSignIn.instance.initialize(
      serverClientId: AppConfig.googleClientId,
    );
    _initialized = true;
  }

  Future<String?> signInAndGetIdToken() async {
    await _ensureInitialized();
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError(
          'Google did not return an ID token. Add an Android OAuth client '
          '(package + SHA-1) in Google Cloud Console and use a Web client ID '
          'as GOOGLE_CLIENT_ID.',
        );
      }
      return idToken;
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return null;
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _ensureInitialized();
    await GoogleSignIn.instance.signOut();
  }
}
