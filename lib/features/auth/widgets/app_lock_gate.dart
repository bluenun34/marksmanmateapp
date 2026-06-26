import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_provider.dart';
import '../../settings/providers/biometric_provider.dart';

class AppLockGate extends ConsumerStatefulWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppLockGate> createState() => _AppLockGateState();
}

class _AppLockGateState extends ConsumerState<AppLockGate>
    with WidgetsBindingObserver {
  bool _unlocked = false;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeLock());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      if (ref.read(biometricLockProvider)) {
        setState(() => _unlocked = false);
      }
    }
    if (state == AppLifecycleState.resumed) {
      _maybeLock();
    }
  }

  Future<void> _maybeLock() async {
    final auth = ref.read(authStateProvider);
    if (!auth.isAuthenticated || auth.isInitializing) {
      setState(() => _unlocked = true);
      return;
    }
    if (!ref.read(biometricLockProvider)) {
      setState(() => _unlocked = true);
      return;
    }
    if (_unlocked || _checking) return;
    await _unlock();
  }

  Future<void> _unlock() async {
    setState(() => _checking = true);
    final ok = await ref
        .read(biometricLockProvider.notifier)
        .authenticate(reason: 'Unlock MarksmanMate to access your shoot log');
    if (mounted) {
      setState(() {
        _checking = false;
        _unlocked = ok;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authStateProvider);
    ref.listen<bool>(biometricLockProvider, (previous, next) {
      if (next && auth.isAuthenticated) {
        setState(() => _unlocked = false);
        _maybeLock();
      }
    });

    if (!auth.isAuthenticated || !ref.watch(biometricLockProvider) || _unlocked) {
      return widget.child;
    }

    return Stack(
      children: [
        widget.child,
        ColoredBox(
          color: Theme.of(context).colorScheme.surface,
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    size: 48,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'MarksmanMate is locked',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Use biometrics or your device PIN to continue',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton.icon(
                    onPressed: _checking ? null : _unlock,
                    icon: _checking
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.fingerprint_rounded),
                    label: Text(_checking ? 'Checking…' : 'Unlock'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
