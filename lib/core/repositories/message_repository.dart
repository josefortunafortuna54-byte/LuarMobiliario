import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/message_model.dart';
import '../services/supabase_service.dart';

class MessageRepository {
  final SupabaseClient _client = SupabaseService.client;

  Future<List<Map<String, dynamic>>> fetchConversations(String userId) async {
    final response = await _client
        .from('messages')
        .select()
        .or('sender_id.eq.$userId,receiver_id.eq.$userId')
        .order('created_at', ascending: false);

    final Map<String, Map<String, dynamic>> convMap = {};
    final Set<String> partnerIds = {};

    final messages = response as List;

    for (final msg in messages) {
      final senderId = msg['sender_id'] as String;
      final receiverId = msg['receiver_id'] as String;
      final partnerId = senderId == userId ? receiverId : senderId;

      if (!convMap.containsKey(partnerId)) {
        partnerIds.add(partnerId);
      }
    }

    if (partnerIds.isNotEmpty) {
      final usersRes = await _client
          .from('users')
          .select('id, name, avatar_url')
          .inFilter('id', partnerIds.toList());

      final Map<String, Map<String, dynamic>> usersMap = {};
      for (final u in usersRes as List) {
        usersMap[u['id'] as String] = u;
      }

      for (final msg in messages) {
        final senderId = msg['sender_id'] as String;
        final receiverId = msg['receiver_id'] as String;
        final partnerId = senderId == userId ? receiverId : senderId;

        if (!convMap.containsKey(partnerId)) {
          final userRes = usersMap[partnerId];
          convMap[partnerId] = {
            'partnerId': partnerId,
            'partnerName': userRes?['name'] ?? 'Utilizador',
            'partnerAvatar': userRes?['avatar_url'] ?? '',
            'lastMessage': msg['content'] ?? '',
            'lastMessageTime': msg['created_at'] ?? '',
            'unreadCount':
                (msg['receiver_id'] == userId && msg['is_read'] == false) ? 1 : 0,
          };
        }
      }
    }

    return convMap.values.toList();
  }

  Future<List<MessageModel>> fetchConversation(
    String userId,
    String otherUserId,
  ) async {
    final response = await _client
        .from('messages')
        .select()
        .or(
          'and(sender_id.eq.$userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$userId)',
        )
        .order('created_at', ascending: true);

    return (response as List)
        .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> markConversationAsRead(String otherUserId, String userId) async {
    await _client
        .from('messages')
        .update({'is_read': true})
        .eq('sender_id', otherUserId)
        .eq('receiver_id', userId)
        .eq('is_read', false);
  }

  Future<MessageModel> send(
    String senderId,
    String receiverId,
    String content,
  ) async {
    final response = await _client
        .from('messages')
        .insert({
          'sender_id': senderId,
          'receiver_id': receiverId,
          'content': content,
        })
        .select()
        .single();

    return MessageModel.fromJson(response);
  }

  Future<int> countUnread(String userId) async {
    final response = await _client
        .from('messages')
        .select('id')
        .eq('receiver_id', userId)
        .eq('is_read', false);
    return (response as List).length;
  }

  RealtimeChannel subscribeToMessages(
    String userId,
    String otherUserId, {
    required void Function(MessageModel message) onNewMessage,
  }) {
    return _client
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
              onNewMessage(newMsg);
            }
          },
        )
        .subscribe();
  }
}