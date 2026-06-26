import 'package:app_links/app_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final deepLinkHandlerProvider = Provider<DeepLinkHandler>((ref) {
  return DeepLinkHandler(ref);
});

class DeepLinkHandler {
  DeepLinkHandler(this._ref);
  // ignore: unused_field
  final Ref _ref;
  final _appLinks = AppLinks();

  Future<void> init(GoRouter router) async {
    final initial = await _appLinks.getInitialLink();
    if (initial != null) {
      _navigate(router, initial);
    }
    _appLinks.uriLinkStream.listen((uri) => _navigate(router, uri));
  }

  void _navigate(GoRouter router, Uri uri) {
    final path = uri.path.isNotEmpty ? uri.path : uri.host;
    if (path.startsWith('/shoot-log')) {
      router.go(uri.path + (uri.hasQuery ? '?${uri.query}' : ''));
      return;
    }
    if (path == 'quick-log' || uri.host == 'quick-log') {
      router.push('/shoot-log/quick${uri.hasQuery ? '?${uri.query}' : ''}');
      return;
    }
    if (path == 'new-session' || uri.host == 'new-session') {
      router.go('/shoot-log/new${uri.hasQuery ? '?${uri.query}' : ''}');
    }
  }
}

class DeepLinkListener extends ConsumerStatefulWidget {
  const DeepLinkListener({super.key, required this.child, required this.router});

  final Widget child;
  final GoRouter router;

  @override
  ConsumerState<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<DeepLinkListener> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(deepLinkHandlerProvider).init(widget.router);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
