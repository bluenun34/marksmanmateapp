import 'package:flutter_test/flutter_test.dart';
import 'package:marksmanmate/shared/models/user_access.dart';
import 'package:marksmanmate/shared/models/user_model.dart';

void main() {
  const proActive = UserModel(
    id: 1,
    name: 'Pro',
    email: 'pro@example.com',
    plan: 'pro_user',
    mobileAccess: true,
  );

  const proInactive = UserModel(
    id: 2,
    name: 'Pro',
    email: 'pro@example.com',
    plan: 'pro_user',
    mobileAccess: false,
  );

  const proLegacy = UserModel(
    id: 5,
    name: 'Pro',
    email: 'pro@example.com',
    plan: 'pro_user',
  );

  const freeUser = UserModel(
    id: 3,
    name: 'Free',
    email: 'free@example.com',
    plan: 'free',
    mobileAccess: false,
  );

  test('mobile_access true with pro_user grants full access', () {
    expect(hasMobileAccess(proActive), isTrue);
    expect(canEnterApp(proActive), isTrue);
    expect(canUseMobileApi(proActive), isTrue);
    expect(showMobileSyncInactiveBanner(proActive), isFalse);
  });

  test('mobile_access false with pro_user allows app entry only', () {
    expect(hasMobileAccess(proInactive), isFalse);
    expect(canEnterApp(proInactive), isTrue);
    expect(canUseMobileApi(proInactive), isFalse);
    expect(showMobileSyncInactiveBanner(proInactive), isTrue);
  });

  test('legacy pro_user without mobile_access may attempt mobile API', () {
    expect(hasMobileAccess(proLegacy), isFalse);
    expect(canEnterApp(proLegacy), isTrue);
    expect(canUseMobileApi(proLegacy), isTrue);
    expect(showMobileSyncInactiveBanner(proLegacy), isFalse);
  });

  test('mobile_access false with free plan blocks app entry', () {
    expect(hasMobileAccess(freeUser), isFalse);
    expect(canEnterApp(freeUser), isFalse);
    expect(canUseMobileApi(freeUser), isFalse);
  });

  test('mobile_access true alone is enough regardless of plan', () {
    const mobileOnly = UserModel(
      id: 4,
      name: 'Mobile',
      email: 'mobile@example.com',
      plan: 'free',
      mobileAccess: true,
    );
    expect(hasMobileAccess(mobileOnly), isTrue);
    expect(canEnterApp(mobileOnly), isTrue);
    expect(canUseMobileApi(mobileOnly), isTrue);
  });

  test('UserModel parses legacy production user JSON', () {
    final user = UserModel.fromJson({
      'id': 1,
      'name': 'Pro',
      'email': 'pro@example.com',
      'plan_key': 'pro_user',
      'avatar_path': null,
    });

    expect(user.plan, 'pro_user');
    expect(user.mobileAccess, isNull);
    expect(canUseMobileApi(user), isTrue);
  });

  test('UserModel parses explicit mobile_access values', () {
    expect(
      UserModel.fromJson({
        'id': 1,
        'name': 'Pro',
        'email': 'pro@example.com',
        'plan_key': 'pro_user',
        'mobile_access': 1,
      }).mobileAccess,
      isTrue,
    );
    expect(
      UserModel.fromJson({
        'id': 1,
        'name': 'Pro',
        'email': 'pro@example.com',
        'plan_key': 'pro_user',
        'mobile_access': 0,
      }).mobileAccess,
      isFalse,
    );
  });

  test('pro_user plan is treated as likely pro user', () {
    expect(proInactive.isLikelyProUser, isTrue);
    expect(freeUser.isLikelyProUser, isFalse);
  });
}
