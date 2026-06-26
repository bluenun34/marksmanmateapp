import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/config/app_config.dart';
import '../../../core/network/auth_session.dart';
import '../../../core/network/api_errors.dart';
import '../../../core/network/api_service.dart';
import '../../../core/network/token_repository.dart';
import '../../../core/sync/sync_status_provider.dart';
import '../../../shared/models/user_model.dart';

// ─── Auth State ───────────────────────────────────────────────────────────────

class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.isInitializing = false,
    this.error,
  });

  final UserModel? user;
  final bool isLoading;
  final bool isInitializing;
  final String? error;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserModel? user,
    bool? isLoading,
    bool? isInitializing,
    String? error,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      isInitializing: isInitializing ?? this.isInitializing,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ─── Auth Notifier ────────────────────────────────────────────────────────────

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    authSessionExpiredHandler = forceLogout;
    _init();
    return const AuthState(isInitializing: true);
  }

  ApiService get _api => ref.read(apiServiceProvider);
  TokenRepository get _tokenRepo => ref.read(tokenRepositoryProvider);

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
        }
      }
    } catch (_) {
      // Never block app launch on auth restore failures.
    } finally {
      state = state.copyWith(isInitializing: false);
      if (state.isAuthenticated) {
        unawaited(_backgroundSync());
      }
    }
  }

  Future<void> _backgroundSync() async {
    await ref.read(syncStatusProvider.notifier).syncAll();
  }

  Future<void> login(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _api.login(email.trim().toLowerCase(), password);
      final token = data['access_token'] ?? data['token'];
      if (token is! String || token.isEmpty) {
        throw const FormatException('Login response did not include a token');
      }

      await _tokenRepo.saveTokens(
        accessToken: token,
        refreshToken: data['refresh_token'] as String? ?? token,
      );

      final embeddedUser = data['user'];
      final user = embeddedUser is Map
          ? UserModel.fromJson(Map<String, dynamic>.from(embeddedUser))
          : await _api.getUser();

      state = state.copyWith(user: user, isLoading: false);
      unawaited(_backgroundSync());
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: messageFromAuthError(e, apiBaseUrl: AppConfig.apiBaseUrl),
        clearUser: true,
      );
    }
  }

  Future<void> logout() async {
    await _tokenRepo.clearTokens();
    ref.read(syncStatusProvider.notifier).reset();
    state = const AuthState();
  }

  void forceLogout() {
    unawaited(logout());
  }
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
