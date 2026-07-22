import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';
import '../services/supabase_service.dart';

class MessageProvider extends ChangeNotifier {
  SupabaseClient get _client => SupabaseService.client;

  List<MessageModel> _messages = [];
  List<Map<String, dynamic>> _conversations = [];
  bool _isLoading = false;
  String? _error;
  RealtimeChannel? _channel;

  List<MessageModel> get messages => _messages;
  List<Map<String, dynamic>> get conversations => _conversations;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadConversations(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client
          .from('messages')
          .select()
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false);

      final Map<String, Map<String, dynamic>> convMap = {};
      for (final msg in response as List) {
        final senderId = msg['sender_id'] as String;
        final receiverId = msg['receiver_id'] as String;
        final partnerId = senderId == userId ? receiverId : senderId;

        if (!convMap.containsKey(partnerId)) {
          final userRes = await _client
              .from('users')
              .select('name, avatar_url')
              .eq('id', partnerId)
              .maybeSingle();

          convMap[partnerId] = {
            'partnerId': partnerId,
            'partnerName': userRes?['name'] ?? 'Utilizador',
            'partnerAvatar': userRes?['avatar_url'] ?? '',
            'lastMessage': msg['content'] ?? '',
            'lastMessageTime': msg['created_at'] ?? '',
            'unreadCount': (msg['receiver_id'] == userId && msg['is_read'] == false) ? 1 : 0,
          };
        }
      }

      _conversations = convMap.values.toList();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMessages(String userId, String otherUserId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _client
          .from('messages')
          .select()
          .or('and(sender_id.eq.$userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$userId)')
          .order('created_at', ascending: true);

      _messages = (response as List)
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();

      await _client
          .from('messages')
          .update({'is_read': true})
          .eq('sender_id', otherUserId)
          .eq('receiver_id', userId)
          .eq('is_read', false);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(String senderId, String receiverId, String content) async {
    try {
      final response = await _client
          .from('messages')
          .insert({
            'sender_id': senderId,
            'receiver_id': receiverId,
            'content': content,
          })
          .select()
          .single();

      _messages.add(MessageModel.fromJson(response));
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void subscribeToMessages(String userId, String otherUserId) {
    _channel?.unsubscribe();
    _channel = _client
        .channel('messages:$userId:$otherUserId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'receiver_id',
            value: userId,
          ),
          callback: (payload) {
            final newMsg = MessageModel.fromJson(payload.newRecord);
            if ((newMsg.senderId == otherUserId && newMsg.receiverId == userId) ||
                (newMsg.senderId == userId && newMsg.receiverId == otherUserId)) {
              _messages.add(newMsg);
              notifyListeners();
            }
          },
        )
        .subscribe();
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _client
          .from('messages')
          .select()
          .eq('receiver_id', userId)
          .eq('is_read', false);
      return (response as List).length;
    } catch (_) {
      return 0;
    }
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}
