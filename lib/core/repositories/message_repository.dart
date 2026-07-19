import '../models/message_model.dart';
import '../services/supabase_service.dart';

class MessageRepository {
  final _client = SupabaseService.client;
  static const _table = 'messages';

  Future<List<Map<String, dynamic>>> getConversations(String userId) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .or('sender_id.eq.$userId,receiver_id.eq.$userId')
          .order('created_at', ascending: false);

      final messages = (response as List<dynamic>)
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();

      final Map<String, MessageModel> latestByPartner = {};
      for (final msg in messages) {
        final partnerId =
            msg.senderId == userId ? msg.receiverId : msg.senderId;
        if (!latestByPartner.containsKey(partnerId)) {
          latestByPartner[partnerId] = msg;
        }
      }

      return latestByPartner.entries
          .map((e) => {
                'partnerId': e.key,
                'lastMessage': e.value,
              })
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<List<MessageModel>> getMessages(
    String userId,
    String otherUserId,
  ) async {
    try {
      final response = await _client
          .from(_table)
          .select()
          .or(
            'and(sender_id.eq.$userId,receiver_id.eq.$otherUserId),and(sender_id.eq.$otherUserId,receiver_id.eq.$userId)',
          )
          .order('created_at', ascending: true);

      return (response as List<dynamic>)
          .map((json) => MessageModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      return [];
    }
  }

  Future<MessageModel> sendMessage(MessageModel message) async {
    final data = message.toJson()..remove('id');

    final response =
        await _client.from(_table).insert(data).select().single();

    return MessageModel.fromJson(response);
  }

  Future<void> markAsRead(String messageId) async {
    await _client
        .from(_table)
        .update({'is_read': true})
        .eq('id', messageId);
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      final response = await _client
          .from(_table)
          .select('id')
          .eq('receiver_id', userId)
          .eq('is_read', false);

      return (response as List<dynamic>).length;
    } catch (e) {
      return 0;
    }
  }
}
