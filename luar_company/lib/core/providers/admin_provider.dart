import 'package:flutter/foundation.dart';

import '../models/user_model.dart';
import '../repositories/admin_repository.dart';
import '../services/notification_preferences.dart';
import '../services/notification_service.dart';

class AdminProvider extends ChangeNotifier {
  final AdminRepository _repository = AdminRepository();

  int _totalProperties = 0;
  int _totalLands = 0;
  int _totalUsers = 0;
  int _totalUnreadMessages = 0;
  List<UserModel> _allUsers = [];
  AdminAnalytics? _analytics;
  bool _isLoading = false;
  String? _error;

  int get totalProperties => _totalProperties;
  int get totalLands => _totalLands;
  int get totalUsers => _totalUsers;
  int get totalUnreadMessages => _totalUnreadMessages;
  List<UserModel> get allUsers => _allUsers;
  AdminAnalytics? get analytics => _analytics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final stats = await _repository.fetchStats();
      _totalProperties = stats.properties;
      _totalLands = stats.lands;
      _totalUsers = stats.users;
      _totalUnreadMessages = stats.unreadMessages;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carrega as métricas agregadas para o painel de análise. Não bloqueia a
  /// UI de estatísticas (falhas ficam apenas registadas no erro).
  Future<void> loadAnalytics() async {
    try {
      _analytics = await _repository.fetchAnalytics();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allUsers = await _repository.fetchUsers();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    try {
      await _repository.updateUserRole(userId, newRole);

      final index = _allUsers.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _allUsers[index] = _allUsers[index].copyWith(role: newRole);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> setUserVerified({
    required String userId,
    required bool verified,
    required String actorId,
  }) async {
    try {
      await _repository.setUserVerified(
        userId: userId,
        verified: verified,
        adminId: actorId,
      );

      // Informa o anunciante do resultado da verificação (ação de admin,
      // autorizada pelo RPC/Edge Function).
      NotificationService().sendNotification(
        userId: userId,
        title: verified ? 'Conta verificada' : 'Verificação removida',
        body:
            verified
                ? 'O seu perfil de anunciante já está verificado.'
                : 'A verificação do seu perfil foi removida.',
        route: '/profile',
        category: NotificationCategory.system,
      );

      final index = _allUsers.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _allUsers[index] = _allUsers[index].copyWith(verified: verified);
        notifyListeners();
      }
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteUser(String userId) async {
    try {
      await _repository.deleteUser(userId);
      _allUsers.removeWhere((u) => u.id == userId);
      _totalUsers = _allUsers.length;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}