import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/message_model.dart';

void main() {
  final fixedDate = DateTime(2025, 3, 10, 14, 30);

  MessageModel createSubject({
    String id = 'm1',
    String senderId = 'u1',
    String receiverId = 'u2',
    String content = 'Olá, tem disponibilidade?',
    bool isRead = true,
    DateTime? createdAt,
  }) {
    return MessageModel(
      id: id,
      senderId: senderId,
      receiverId: receiverId,
      content: content,
      isRead: isRead,
      createdAt: createdAt ?? fixedDate,
    );
  }

  group('fromJson', () {
    test('parses a complete JSON map', () {
      final json = {
        'id': 'm2',
        'sender_id': 'u3',
        'receiver_id': 'u5',
        'content': 'Sim, está disponível',
        'is_read': true,
        'created_at': '2025-02-01T10:00:00.000',
      };

      final m = MessageModel.fromJson(json);

      expect(m.id, 'm2');
      expect(m.senderId, 'u3');
      expect(m.receiverId, 'u5');
      expect(m.content, 'Sim, está disponível');
      expect(m.isRead, true);
      expect(m.createdAt, DateTime(2025, 2, 1, 10, 0));
    });

    test('defaults isRead to false when null', () {
      final m = MessageModel.fromJson(<String, dynamic>{});
      expect(m.isRead, false);
    });

    test('defaults string fields to empty when null', () {
      final m = MessageModel.fromJson(<String, dynamic>{});
      expect(m.id, '');
      expect(m.senderId, '');
      expect(m.receiverId, '');
      expect(m.content, '');
    });

    test('uses DateTime.now() for missing date', () {
      final before = DateTime.now();
      final m = MessageModel.fromJson(<String, dynamic>{});
      final after = DateTime.now();

      expect(m.createdAt.isAfter(before), isTrue);
      expect(m.createdAt.isBefore(after), isTrue);
    });
  });

  group('toJson', () {
    test('serializes all fields correctly', () {
      final m = createSubject(isRead: false, createdAt: DateTime(2025, 1, 1));

      final json = m.toJson();

      expect(json['id'], 'm1');
      expect(json['sender_id'], 'u1');
      expect(json['receiver_id'], 'u2');
      expect(json['content'], 'Olá, tem disponibilidade?');
      expect(json['is_read'], false);
      expect(json['created_at'], '2025-01-01T00:00:00.000');
    });

    test('uses snake_case keys', () {
      final json = createSubject().toJson();
      expect(json.containsKey('sender_id'), isTrue);
      expect(json.containsKey('receiver_id'), isTrue);
      expect(json.containsKey('is_read'), isTrue);
      expect(json.containsKey('created_at'), isTrue);
    });

    test('has 6 keys', () {
      final json = createSubject().toJson();
      expect(json.length, 6);
    });
  });

  group('fromJson ↔ toJson round trip', () {
    test('preserves all values through serialization', () {
      final original = createSubject(
        id: 'rt1',
        senderId: 'u10',
        receiverId: 'u20',
        content: 'Mensagem de teste',
        isRead: true,
        createdAt: DateTime(2024, 12, 25, 8, 30),
      );

      final restored = MessageModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.senderId, original.senderId);
      expect(restored.receiverId, original.receiverId);
      expect(restored.content, original.content);
      expect(restored.isRead, original.isRead);
      expect(restored.createdAt, original.createdAt);
    });
  });

  group('copyWith', () {
    test('returns identical instance when no arguments', () {
      final original = createSubject();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.senderId, original.senderId);
      expect(copy.receiverId, original.receiverId);
      expect(copy.content, original.content);
      expect(copy.isRead, original.isRead);
      expect(copy.createdAt, original.createdAt);
    });

    test('overrides only specified fields', () {
      final original = createSubject();
      final copy = original.copyWith(content: 'Nova mensagem');

      expect(copy.content, 'Nova mensagem');
      expect(copy.id, original.id);
      expect(copy.senderId, original.senderId);
      expect(copy.isRead, original.isRead);
    });

    test('can change isRead', () {
      final original = createSubject(isRead: false);
      final copy = original.copyWith(isRead: true);

      expect(copy.isRead, true);
      expect(original.isRead, false);
    });

    test('can change multiple fields at once', () {
      final original = createSubject();
      final copy = original.copyWith(
        senderId: 'u99',
        receiverId: 'u88',
        content: 'Atualizado',
      );

      expect(copy.senderId, 'u99');
      expect(copy.receiverId, 'u88');
      expect(copy.content, 'Atualizado');
      expect(copy.id, original.id);
    });

    test('original instance is not mutated', () {
      final original = createSubject();
      original.copyWith(content: 'Changed', isRead: true);

      expect(original.content, 'Olá, tem disponibilidade?');
      expect(original.isRead, true);
    });
  });
}
