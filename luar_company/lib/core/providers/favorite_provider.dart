import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/favorite_model.dart';
import '../models/property_model.dart';
import '../models/land_model.dart';
import '../repositories/favorite_repository.dart';
import '../services/guest_favorites_service.dart';

/// Resultado de um toggle de favorito.
///
/// Distingue "removido" de "falhou": o `bool` anterior devolvia `false` nos
/// dois casos, o que fazia o ecrã mostrar o coração por preencher mesmo
/// quando a gravação falhava.
enum FavoriteToggleResult { added, removed, failed }

class FavoriteProvider extends ChangeNotifier {
  FavoriteProvider({FavoriteRepository? repository})
    : _repository = repository ?? FavoriteRepository();

  final FavoriteRepository _repository;

  /// Identificador usado quando o utilizador navega sem conta (convidado).
  /// Nesse modo os favoritos são guardados localmente no dispositivo.
  static const String guestUserId = '__guest__';

  List<FavoriteModel> _favorites = [];
  final Map<String, int> _likeCounts = {};
  bool _isLoading = false;
  String? _loadedFor;

  bool get isGuest => _loadedFor == guestUserId;

  List<FavoriteModel> get favorites => _favorites;
  bool get isLoading => _isLoading;

  /// Contagem de favoritos por imóvel (contador de "gostos" do Discover).
  Map<String, int> get likeCounts => Map.unmodifiable(_likeCounts);

  int likeCount(String propertyId) {
    final count = _likeCounts[propertyId] ?? 0;
    final likedByGuest =
        _loadedFor == guestUserId &&
        _favorites.any(
          (f) => f.userId == guestUserId && f.propertyId == propertyId,
        );
    if (likedByGuest && count < 1) return 1;
    return count;
  }

  /// Carrega as contagens de favoritos dos [propertyIds] ainda não conhecidos.
  /// Falhas (offline, sem backend) são silenciadas: o feed mantém-se funcional
  /// apenas sem contador.
  Future<void> loadLikeCounts(List<String> propertyIds) async {
    final pending = propertyIds
        .where((id) => id.isNotEmpty && !_likeCounts.containsKey(id))
        .toList();
    if (pending.isEmpty) return;

    try {
      final counts = await _repository.countLikes(pending);
      _likeCounts.addAll(counts);
      notifyListeners();
    } catch (_) {
      // Sem backend disponível — mantém os ids como "por carregar" para
      // permitir nova tentativa na próxima página.
    }
  }

  /// Ajusta a contagem local após um toggle, sem nova query.
  ///
  /// Quando a contagem ainda não foi carregada semeia-a a partir de zero, para
  /// que o contador do Discover reflita o toggle em vez de ficar congelado.
  void _adjustLikeCount(String? propertyId, {required int delta}) {
    if (propertyId == null || propertyId.isEmpty) return;
    final current = _likeCounts[propertyId] ?? 0;
    _likeCounts[propertyId] = (current + delta).clamp(0, 1 << 31);
  }

  /// Recarrega a contagem de um imóvel a partir da RPC `favorite_counts`.
  ///
  /// O `upsert` do repositório é idempotente, por isso não dá para saber
  /// pelo resultado se a linha já existia: a contagem real só é garantida
  /// depois de a consultar.
  Future<void> _refreshLikeCount(String? propertyId) async {
    if (propertyId == null || propertyId.isEmpty) return;
    try {
      final counts = await _repository.countLikes([propertyId]);
      final total = counts[propertyId];
      if (total == null) return;
      _likeCounts[propertyId] = total;
      notifyListeners();
    } catch (_) {
      // Sem backend disponível — mantém a contagem otimista local.
    }
  }

  Future<void> loadFavorites(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      if (userId == guestUserId) {
        _favorites = await _loadGuestFavorites();
      } else {
        _favorites = await _repository.fetchFavorites(userId);
      }
      _loadedFor = userId;
    } catch (e) {
      _favorites = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega os favoritos de [userId] apenas se ainda não estiverem em memória.
  ///
  /// Evita repetir a query em cada ecrã visitado durante a mesma sessão.
  Future<void> ensureLoaded(String userId) async {
    if (_loadedFor == userId) return;
    await loadFavorites(userId);
  }

  Future<List<FavoriteModel>> _loadGuestFavorites() async {
    final propertyIds = await GuestFavorites.propertyIds();
    final landIds = await GuestFavorites.landIds();
    return [
      for (final id in propertyIds)
        FavoriteModel(
          id: 'guest_p_$id',
          userId: guestUserId,
          propertyId: id,
          createdAt: DateTime.now(),
        ),
      for (final id in landIds)
        FavoriteModel(
          id: 'guest_l_$id',
          userId: guestUserId,
          landId: id,
          createdAt: DateTime.now(),
        ),
    ];
  }

  /// Alterna o favorito de [userId] para o imóvel/terreno indicado.
  ///
  /// Devolve [FavoriteToggleResult] para que o ecrã consiga distinguir
  /// "adicionado", "removido" e "falhou" — o `bool` anterior tratava falha
  /// como remoção, e o erro acabava silenciado sem qualquer aviso.
  Future<FavoriteToggleResult> toggleFavorite(
    String userId, {
    String? propertyId,
    String? landId,
  }) async {
    if (propertyId == null && landId == null) {
      return FavoriteToggleResult.failed;
    }

    if (userId == guestUserId) {
      return _toggleGuestFavorite(propertyId: propertyId, landId: landId);
    }

    try {
      final existingIndex = _favorites.indexWhere(
        (f) =>
            f.userId == userId &&
            ((propertyId != null && f.propertyId == propertyId) ||
                (landId != null && f.landId == landId)),
      );

      if (existingIndex != -1) {
        await _repository.remove(
          userId: userId,
          propertyId: propertyId,
          landId: landId,
        );

        _favorites.removeAt(existingIndex);
        _adjustLikeCount(propertyId, delta: -1);
        notifyListeners();
        return FavoriteToggleResult.removed;
      } else {
        final newFavorite = await _repository.add(
          userId: userId,
          propertyId: propertyId,
          landId: landId,
        );

        // A linha pode já existir no servidor (o `upsert` é idempotente):
        // evita duplicar no estado local.
        _favorites.removeWhere(
          (f) =>
              f.userId == userId &&
              ((propertyId != null && f.propertyId == propertyId) ||
                  (landId != null && f.landId == landId)),
        );
        _favorites.insert(0, newFavorite);
        _adjustLikeCount(propertyId, delta: 1);
        notifyListeners();

        // Confirma a contagem real (o `upsert` não diz se a linha já existia).
        unawaited(_refreshLikeCount(propertyId));

        return FavoriteToggleResult.added;
      }
    } catch (e) {
      return FavoriteToggleResult.failed;
    }
  }

  /// Alterna um favorito local (modo convidado), persistindo no dispositivo.
  Future<FavoriteToggleResult> _toggleGuestFavorite({
    String? propertyId,
    String? landId,
  }) async {
    try {
      final bool added;
      if (propertyId != null && propertyId.isNotEmpty) {
        added = await GuestFavorites.toggleProperty(propertyId);
      } else if (landId != null && landId.isNotEmpty) {
        added = await GuestFavorites.toggleLand(landId);
      } else {
        return FavoriteToggleResult.failed;
      }

      final existingIndex = _favorites.indexWhere(
        (f) =>
            f.userId == guestUserId &&
            ((propertyId != null && f.propertyId == propertyId) ||
                (landId != null && f.landId == landId)),
      );

      if (added && existingIndex == -1) {
        _favorites.insert(
          0,
          FavoriteModel(
            id: 'guest_${propertyId ?? landId}',
            userId: guestUserId,
            propertyId: propertyId,
            landId: landId,
            createdAt: DateTime.now(),
          ),
        );
      } else if (!added && existingIndex != -1) {
        _favorites.removeAt(existingIndex);
      }

      // O like de convidado é local, mas o contador do Discover deve refletir
      // a ação imediatamente (antes ficava sempre a 0).
      _adjustLikeCount(propertyId, delta: added ? 1 : -1);

      notifyListeners();
      return added ? FavoriteToggleResult.added : FavoriteToggleResult.removed;
    } catch (e) {
      return FavoriteToggleResult.failed;
    }
  }

  bool isFavorite(String userId, {String? propertyId, String? landId}) {
    return _favorites.any(
      (f) =>
          f.userId == userId &&
          ((propertyId != null && f.propertyId == propertyId) ||
              (landId != null && f.landId == landId)),
    );
  }

  Future<List<PropertyModel>> getFavoriteProperties() async {
    final propertyIds = _favorites
        .where((f) => f.propertyId != null && f.propertyId!.isNotEmpty)
        .map((f) => f.propertyId!)
        .toList();

    try {
      return await _repository.fetchFavoriteProperties(propertyIds);
    } catch (e) {
      return [];
    }
  }

  Future<List<LandModel>> getFavoriteLands() async {
    final landIds = _favorites
        .where((f) => f.landId != null && f.landId!.isNotEmpty)
        .map((f) => f.landId!)
        .toList();

    try {
      return await _repository.fetchFavoriteLands(landIds);
    } catch (e) {
      return [];
    }
  }

  void clearFavorites() {
    _favorites = [];
    _loadedFor = null;
    notifyListeners();
  }
}
