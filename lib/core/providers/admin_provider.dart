import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user_model.dart';
import '../services/supabase_service.dart';

class AdminProvider extends ChangeNotifier {
  SupabaseClient get _client => SupabaseService.client;

  int _totalProperties = 0;
  int _totalLands = 0;
  int _totalUsers = 0;
  int _totalUnreadMessages = 0;
  List<UserModel> _allUsers = [];
  bool _isLoading = false;
  String? _error;

  int get totalProperties => _totalProperties;
  int get totalLands => _totalLands;
  int get totalUsers => _totalUsers;
  int get totalUnreadMessages => _totalUnreadMessages;
  List<UserModel> get allUsers => _allUsers;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final results = await Future.wait([
        _client.from('properties').select().eq('is_available', true),
        _client.from('lands').select().eq('is_available', true),
        _client.from('users').select(),
        _client.from('messages').select().eq('is_read', false),
      ]);

      _totalProperties = (results[0] as List).length;
      _totalLands = (results[1] as List).length;
      _totalUsers = (results[2] as List).length;
      _totalUnreadMessages = (results[3] as List).length;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadUsers() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client
          .from('users')
          .select()
          .order('created_at', ascending: false);

      _allUsers = (response as List)
          .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
