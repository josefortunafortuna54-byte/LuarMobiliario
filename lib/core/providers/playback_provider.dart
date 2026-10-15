import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Preferência de reprodução automática de vídeos (Discover, detalhes).
///
/// Quando desativada, os vídeos do feed não iniciam sozinhos — o utilizador
/// tem de tocar para reproduzir. Persistida em [SharedPreferences].
class PlaybackProvider extends ChangeNotifier {
  PlaybackProvider(this._prefs);

  final SharedPreferences _prefs;

  bool _autoplay = true;

  bool get autoplay => _autoplay;

  static Future<PlaybackProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    final provider = PlaybackProvider(prefs);
    provider._autoplay = prefs.getBool(AppConstants.keyAutoplayVideos) ?? true;
    return provider;
  }

  Future<void> setAutoplay(bool value) async {
    if (_autoplay == value) return;
    _autoplay = value;
    await _prefs.setBool(AppConstants.keyAutoplayVideos, value);
    notifyListeners();
  }
}
