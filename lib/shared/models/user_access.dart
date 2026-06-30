import 'user_model.dart';

/// Plans that may enter the app shell even when [UserModel.mobileAccess] is false.
const mobileAccessPlanKeys = {'pro_user'};

/// Authoritative server flag for mobile API routes (`api.mobile_access`).
bool hasMobileAccess(UserModel user) => user.mobileAccess == true;

/// Whether the user may open the app shell (dashboard, tools, etc.).
bool canEnterApp(UserModel user) =>
    hasMobileAccess(user) || user.plan == 'pro_user';

/// Whether the app should call mobile API routes (sync, locker, notifications).
///
/// When [UserModel.mobileAccess] is absent (legacy `/api/user` responses), Pro plan
/// users may attempt sync and the server remains authoritative via 403.
bool canUseMobileApi(UserModel user) {
  final flag = user.mobileAccess;
  if (flag == true) return true;
  if (flag == false) return false;
  return user.plan == 'pro_user';
}

/// Non-blocking banner when the server explicitly reports inactive mobile access.
bool showMobileSyncInactiveBanner(UserModel user) =>
    user.mobileAccess == false && user.plan == 'pro_user';

const mobileSyncInactiveMessage =
    'Mobile sync is inactive — renew Pro on the website and refresh.';

extension UserModelAccess on UserModel {
  bool get isLikelyProUser =>
      plan != null && mobileAccessPlanKeys.contains(plan);
}
