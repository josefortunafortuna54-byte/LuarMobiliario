import 'package:flutter/material.dart';

/// Acesso ao Navigator global para deep links (notificações, partilha).
class AppNavigator {
  AppNavigator._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static NavigatorState? get navigator => navigatorKey.currentState;

  /// Observer para ecrãs que precisam de reagir a serem cobertos/pousados
  /// (ex.: pausar o vídeo do Discover). Registar em `MaterialApp
  /// .navigatorObservers`.
  static final RouteObserver<PageRoute<dynamic>> routeObserver =
      RouteObserver<PageRoute<dynamic>>();
}
