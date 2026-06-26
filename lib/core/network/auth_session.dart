import 'package:flutter/foundation.dart';

/// Called when API auth cannot be refreshed — wire to [AuthNotifier.forceLogout].
typedef AuthSessionExpiredHandler = void Function();

AuthSessionExpiredHandler? authSessionExpiredHandler;

void notifyAuthSessionExpired() {
  authSessionExpiredHandler?.call();
}
