import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/message_model.dart';
import '../repositories/message_repository.dart';

class MessageProvider extends ChangeNotifier {
  final MessageRepository _repository = MessageRepository();

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
      _conversations = await _repository.fetchConversations(userId);
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
      _messages = await _repository.fetchConversation(userId, otherUserId);

      await _repository.markConversationAsRead(otherUserId, userId);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> sendMessage(
    String senderId,
    String receiverId,
    String content,
  ) async {
    if (content.trim().isEmpty) return;

    try {
      final message = await _repository.send(senderId, receiverId, content);
      _messages.add(message);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void subscribeToMessages(String userId, String otherUserId) {
    _channel?.unsubscribe();
    _channel = _repository.subscribeToMessages(
      userId,
      otherUserId,
      onNewMessage: (newMsg) {
        _messages.add(newMsg);
        notifyListeners();
      },
    );
  }

  void unsubscribe() {
    _channel?.unsubscribe();
    _channel = null;
  }

  Future<int> getUnreadCount(String userId) async {
    try {
      return await _repository.countUnread(userId);
    } catch (_) {
      return 0;
    }
  }

  void clearMessages() {
    _messages = [];
    notifyListeners();
  }
}