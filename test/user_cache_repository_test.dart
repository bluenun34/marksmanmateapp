import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/core/auth/user_cache_repository.dart';
import 'package:marksmanmate/shared/models/user_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('UserCacheRepository', () {
    late UserCacheRepository repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      repository = UserCacheRepository();
    });

    test('round-trips user profile json', () async {
      const user = UserModel(
        id: 42,
        name: 'Pat Shooter',
        email: 'pat@example.com',
        plan: 'pro_user',
        mobileAccess: true,
      );

      await repository.save(user);
      final restored = await repository.load();

      expect(restored, isNotNull);
      expect(restored!.id, 42);
      expect(restored.email, 'pat@example.com');
      expect(restored.plan, 'pro_user');
      expect(restored.mobileAccess, isTrue);
    });

    test('clear removes cached profile', () async {
      await repository.save(
        const UserModel(
          id: 1,
          name: 'A',
          email: 'a@example.com',
        ),
      );

      await repository.clear();

      expect(await repository.load(), isNull);
    });
  });
}
