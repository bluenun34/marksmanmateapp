import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/core/config/app_config.dart';

void main() {
  test('AppConfig defines dev and production URLs', () {
    expect(AppConfig.defaultDevApiBaseUrl, 'http://marksmanmate.test/api');
    expect(AppConfig.productionApiBaseUrl, 'https://marksmanmate.com/api');
    expect(AppConfig.apiBaseUrl, isNotEmpty);
  });
}
