import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/network/auth_session.dart';
import '../../../core/network/api_errors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/token_repository.dart';
import '../../../core/sync/sync_status_provider.dart';
import '../../../shared/models/user_access.dart' as user_access;
import '../services/google_sign_in_service.dart';
import '../../../shared/models/user_model.dart';

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.isInitializing = false,
    this.isRefreshingProfile = false,
    this.error,
  });

  final UserModel? user;
  final bool isLoading;
  final bool isInitializing;
  final bool isRefreshingProfile;
  final String? error;

  bool get isAuthenticated => user != null;

  bool get hasMobileAccess =>
      user != null && user_access.hasMobileAccess(user!);

  bool get canEnterApp =>
      user != null && user_access.canEnterApp(user!);

  /// Mobile API features (sync, locker, notifications API).
  bool get canUseApp => user != null && user_access.canUseMobileApi(user!);

  bool get showMobileSyncInactiveBanner =>
      user != null && user_access.showMobileSyncInactiveBanner(user!);

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isInitializing,
    bool? isRefreshingProfile,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      isRefreshingProfile:
          isRefreshingProfile ?? this.isRefreshingProfile,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    authSessionExpiredHandler = forceLogout;
    _init();
    return const AuthState(isInitializing: true);
  }

  ApiService get _api => ref.read(apiServiceProvider);
  TokenRepository get _tokenRepo => ref.read(tokenRepositoryProvider);
  GoogleSignInService get _google => ref.read(googleSignInServiceProvider);

  Future<void> _completeTokenLogin(Map<String, dynamic> data) async {
    final token = data['access_token'] ?? data['token'];
    if (token is! String || token.isEmpty) {
      throw const FormatException('Login response did not include a token');
    }

    await _tokenRepo.saveTokens(
      accessToken: token,
      refreshToken: data['refresh_token'] as String? ?? token,
    );

    final user = await _api.getUser();

    state = state.copyWith(user: user, isLoading: false);

    if (state.canUseApp) {
      unawaited(_backgroundSync());
    }
  }

  Future<void> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final idToken = await _google.signInAndGetIdToken();
      if (idToken == null) {
        state = state.copyWith(isLoading: false);
        return;
      }

      final data = await _api.loginWithGoogle(idToken);
      await _completeTokenLogin(data);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: messageFromAuthError(e, apiBaseUrl: AppConfig.apiBaseUrl),
        clearUser: true,
      );
    }
  }

  Future<void> _init() async {
    try {
      final token = await _tokenRepo
          .getAccessToken()
          .timeout(const Duration(seconds: 5), onTimeout: () => null);
      if (token != null) {
        try {
          final user = await _api
              .getUser()
              .timeout(const Duration(seconds: 10));
          state = state.copyWith(user: user);
        } catch (_) {
          await _tokenRepo.clearTokens();
          state = const AuthState();
        }
      }
    } catch (_) {
      // Never block app launch on auth restore failures.
    } finally {
      state = state.copyWith(isInitializing: false);
      if (state.canUseApp) {
        unawaited(_backgroundSync());
      }
    }
  }

  Future<void> refreshProfile() async {
    if (!state.isAuthenticated) return;

    state = state.copyWith(isRefreshingProfile: true, clearError: true);
    try {
      final user = await _api.getUser();
      state = state.copyWith(user: user, isRefreshingProfile: false);

      if (state.canUseApp) {
        unawaited(_backgroundSync());
      }
    } catch (e) {
      state = state.copyWith(
        isRefreshingProfile: false,
        error: messageFromApiError(e),
      );
    }
  }

  Future<void> _backgroundSync() async {
    if (!state.canUseApp) return;
    await ref.read(syncStatusProvider.notifier).syncAll();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _api.login(email.trim().toLowerCase(), password);
      await _completeTokenLogin(data);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: messageFromAuthError(e, apiBaseUrl: AppConfig.apiBaseUrl),
        clearUser: true,
      );
    }
  }

  Future<void> logout() async {
    try {
      await _api.logout();
    } catch (_) {}
    try {
      await _google.signOut();
    } catch (_) {}
    await _tokenRepo.clearTokens();
    ref.read(syncStatusProvider.notifier).reset();
    state = const AuthState();
  }

  void forceLogout() {
    unawaited(logout());
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);

final hasMobileAccessProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).hasMobileAccess;
});

final canEnterAppProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).canEnterApp;
});

final canUseAppProvider = Provider<bool>((ref) {
  return ref.watch(authStateProvider).canUseApp;
});
