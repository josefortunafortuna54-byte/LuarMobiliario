import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Expõe o estado de conectividade da app como [ChangeNotifier].
///
/// [isOnline] começa a `true` (assumir online até prova em contrário) e é
/// atualizado pela [ConnectivityService.init]. Os consumidores (banner
/// offline, retry automático) reagem via `notifyListeners`.
class ConnectivityService extends ChangeNotifier {
  ConnectivityService({Connectivity? connectivity})
    : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  Future<void> init() async {
    _subscription?.cancel();
    _subscription = _connectivity.onConnectivityChanged.listen(_update);
    await _checkNow();
  }

  Future<void> _checkNow() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _update(results);
    } catch (_) {
      // Em plataformas sem suporte, mantém o estado atual.
    }
  }

  void _update(List<ConnectivityResult> results) {
    final online = results.any(
      (r) =>
          r == ConnectivityResult.wifi ||
          r == ConnectivityResult.mobile ||
          r == ConnectivityResult.ethernet ||
          r == ConnectivityResult.vpn,
    );
    if (online == _isOnline) return;
    _isOnline = online;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
