import 'dart:async';



import 'package:flutter/widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';



import '../../features/auth/providers/auth_provider.dart';

import '../location/location_prefetch_provider.dart';

import 'sync_status_provider.dart';



/// Syncs when auth is ready at startup and when the app returns to foreground.

class SyncOnResume extends ConsumerStatefulWidget {

  const SyncOnResume({super.key, required this.child});



  final Widget child;



  @override

  ConsumerState<SyncOnResume> createState() => _SyncOnResumeState();

}



class _SyncOnResumeState extends ConsumerState<SyncOnResume>

    with WidgetsBindingObserver {

  bool _startupSyncAttempted = false;



  @override

  void initState() {

    super.initState();

    WidgetsBinding.instance.addObserver(this);

    WidgetsBinding.instance.addPostFrameCallback((_) => _tryStartupSync());

  }



  @override

  void dispose() {

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();

  }



  @override

  void didChangeAppLifecycleState(AppLifecycleState state) {

    if (state == AppLifecycleState.resumed) {

      _onResume();

    }

  }



  Future<void> _tryStartupSync() async {

    if (_startupSyncAttempted) return;

    final auth = ref.read(authStateProvider);

    if (!auth.canEnterApp || auth.isInitializing) return;

    _startupSyncAttempted = true;

    if (!auth.canUseApp) {

      if (auth.showMobileSyncInactiveBanner) {

        unawaited(ref.read(authStateProvider.notifier).refreshProfile());

      }

      return;

    }

    await _sync();

  }



  Future<void> _onResume() async {

    final auth = ref.read(authStateProvider);

    if (!auth.isAuthenticated || auth.isInitializing) return;

    if (!auth.canEnterApp) return;

    if (!auth.canUseApp) {

      if (auth.showMobileSyncInactiveBanner) {

        unawaited(ref.read(authStateProvider.notifier).refreshProfile());

      }

      return;

    }

    await _sync();

  }



  Future<void> _sync() async {

    final auth = ref.read(authStateProvider);

    if (!auth.canUseApp || auth.isInitializing) return;

    unawaited(ref.read(locationPrefetchProvider.notifier).prefetch());

    await ref.read(syncStatusProvider.notifier).syncAll();

  }



  @override

  Widget build(BuildContext context) {

    ref.listen<AuthState>(authStateProvider, (previous, next) {

      if (previous?.isInitializing == true &&

          !next.isInitializing &&

          next.canEnterApp &&

          !_startupSyncAttempted) {

        _startupSyncAttempted = true;

        if (next.canUseApp) {

          unawaited(_sync());

        } else if (next.showMobileSyncInactiveBanner) {

          unawaited(ref.read(authStateProvider.notifier).refreshProfile());

        }

      }

    });

    return widget.child;

  }

}

