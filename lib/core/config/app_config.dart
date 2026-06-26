import 'package:flutter/foundation.dart';

/// Runtime configuration via `--dart-define` / `--dart-define-from-file`.
///
/// Priority:
/// 1. `API_BASE_URL` dart-define (explicit override)
/// 2. Debug builds → local Laravel dev server ([config/dev.env.json])
/// 3. Release builds → production API
class AppConfig {
  AppConfig._();

  static const _override = String.fromEnvironment('API_BASE_URL');

  static const productionApiBaseUrl = 'https://marksmanmate.com/api';
  static const defaultDevApiBaseUrl = 'http://marksmanmate.test/api';

  static String get websiteBaseUrl {
    if (isProduction) return 'https://marksmanmate.com';
    if (kDebugMode) return 'http://marksmanmate.test';
    return 'https://marksmanmate.com';
  }

  static String get registerUrl => '$websiteBaseUrl/register';
  static String get forgotPasswordUrl => '$websiteBaseUrl/forgot-password';
  static String get profileUrl => '$websiteBaseUrl/app/profile';

  static String get apiBaseUrl {
    if (_override.isNotEmpty) return _override;
    if (kDebugMode) return defaultDevApiBaseUrl;
    return productionApiBaseUrl;
  }

  static bool get isProduction =>
      apiBaseUrl.startsWith('https://') &&
      apiBaseUrl.contains('marksmanmate.com');
}
