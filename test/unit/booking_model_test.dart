import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/booking_model.dart';

void main() {
  final fixedDate = DateTime(2025, 3, 10);
  final fixedCreatedAt = DateTime(2025, 1, 5, 8, 30);

  BookingModel createSubject({
    String id = 'b1',
    String propertyId = 'p1',
    String userId = 'u1',
    String userName = 'Carlos',
    String userPhone = '+244900000000',
    DateTime? date,
    String time = '10:00',
    BookingStatus status = BookingStatus.pending,
    String notes = 'Visita rápida',
    DateTime? createdAt,
  }) {
    return BookingModel(
      id: id,
      propertyId: propertyId,
      userId: userId,
      userName: userName,
      userPhone: userPhone,
      date: date ?? fixedDate,
      time: time,
      status: status,
      notes: notes,
      createdAt: createdAt ?? fixedCreatedAt,
    );
  }

  group('BookingStatus', () {
    test('has four values', () {
      expect(BookingStatus.values.length, 4);
    });

    test('contains all expected statuses', () {
      expect(BookingStatus.values, contains(BookingStatus.pending));
      expect(BookingStatus.values, contains(BookingStatus.confirmed));
      expect(BookingStatus.values, contains(BookingStatus.cancelled));
      expect(BookingStatus.values, contains(BookingStatus.completed));
    });
  });

  group('fromJson', () {
    test('parses a complete JSON map', () {
      final json = {
        'id': 'b2',
        'property_id': 'p5',
        'user_id': 'u3',
        'user_name': 'Ana',
        'user_phone': '+244911111111',
        'date': '2025-06-15T00:00:00.000',
        'time': '14:30',
        'status': 'confirmed',
        'notes': 'Confirmado pelo agente',
        'created_at': '2025-01-15T09:00:00.000',
      };

      final b = BookingModel.fromJson(json);

      expect(b.id, 'b2');
      expect(b.propertyId, 'p5');
      expect(b.userId, 'u3');
      expect(b.userName, 'Ana');
      expect(b.userPhone, '+244911111111');
      expect(b.date, DateTime(2025, 6, 15));
      expect(b.time, '14:30');
      expect(b.status, BookingStatus.confirmed);
      expect(b.notes, 'Confirmado pelo agente');
      expect(b.createdAt, DateTime(2025, 1, 15, 9, 0));
    });

    test('defaults to pending for unknown status', () {
      final b = BookingModel.fromJson({'status': 'unknown'});
      expect(b.status, BookingStatus.pending);
    });

    test('defaults to pending when status is null', () {
      final b = BookingModel.fromJson(<String, dynamic>{'status': null});
      expect(b.status, BookingStatus.pending);
    });

    test('handles all status strings', () {
      expect(
        BookingModel.fromJson({'status': 'pending'}).status,
        BookingStatus.pending,
      );
      expect(
        BookingModel.fromJson({'status': 'confirmed'}).status,
        BookingStatus.confirmed,
      );
      expect(
        BookingModel.fromJson({'status': 'cancelled'}).status,
        BookingStatus.cancelled,
      );
      expect(
        BookingModel.fromJson({'status': 'completed'}).status,
        BookingStatus.completed,
      );
    });

    test('defaults string fields to empty when null', () {
      final b = BookingModel.fromJson(<String, dynamic>{});
      expect(b.id, '');
      expect(b.propertyId, '');
      expect(b.userId, '');
      expect(b.userName, '');
      expect(b.userPhone, '');
      expect(b.time, '');
      expect(b.notes, '');
    });

    test('uses DateTime.now() for missing dates', () {
      final before = DateTime.now().subtract(const Duration(milliseconds: 10));
      final b = BookingModel.fromJson(<String, dynamic>{});
      final after = DateTime.now().add(const Duration(milliseconds: 10));

      expect(b.date.isAfter(before), isTrue);
      expect(b.date.isBefore(after), isTrue);
      expect(b.createdAt.isAfter(before), isTrue);
      expect(b.createdAt.isBefore(after), isTrue);
    });
  });

  group('toJson', () {
    test('serializes all fields correctly', () {
      final b = createSubject(
        status: BookingStatus.completed,
        date: DateTime(2025, 1, 1),
        createdAt: DateTime(2025, 6, 15),
      );

      final json = b.toJson();

      expect(json['id'], 'b1');
      expect(json['property_id'], 'p1');
      expect(json['user_id'], 'u1');
      expect(json['user_name'], 'Carlos');
      expect(json['user_phone'], '+244900000000');
      expect(json['date'], '2025-01-01T00:00:00.000');
      expect(json['time'], '10:00');
      expect(json['status'], 'completed');
      expect(json['notes'], 'Visita rápida');
      expect(json['created_at'], '2025-06-15T00:00:00.000');
    });

    test('uses snake_case keys', () {
      final json = createSubject().toJson();
      expect(json.containsKey('property_id'), isTrue);
      expect(json.containsKey('user_id'), isTrue);
      expect(json.containsKey('user_name'), isTrue);
      expect(json.containsKey('user_phone'), isTrue);
      expect(json.containsKey('created_at'), isTrue);
    });

    test('has 10 keys', () {
      final json = createSubject().toJson();
      expect(json.length, 10);
    });
  });

  group('fromJson ↔ toJson round trip', () {
    test('preserves all values through serialization', () {
      final original = createSubject(
        id: 'rt1',
        propertyId: 'p99',
        userId: 'u42',
        userName: 'Round Trip',
        userPhone: '+244999999999',
        date: DateTime(2025, 8, 20, 10, 30),
        time: '15:00',
        status: BookingStatus.cancelled,
        notes: 'Teste round trip',
        createdAt: DateTime(2024, 12, 1, 8, 0),
      );

      final restored = BookingModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.propertyId, original.propertyId);
      expect(restored.userId, original.userId);
      expect(restored.userName, original.userName);
      expect(restored.userPhone, original.userPhone);
      expect(restored.date, original.date);
      expect(restored.time, original.time);
      expect(restored.status, original.status);
      expect(restored.notes, original.notes);
      expect(restored.createdAt, original.createdAt);
    });
  });

  group('copyWith', () {
    test('returns identical instance when no arguments', () {
      final original = createSubject();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.propertyId, original.propertyId);
      expect(copy.userName, original.userName);
      expect(copy.status, original.status);
    });

    test('overrides only specified fields', () {
      final original = createSubject();
      final copy = original.copyWith(
        userName: 'Maria',
        status: BookingStatus.confirmed,
      );

      expect(copy.userName, 'Maria');
      expect(copy.status, BookingStatus.confirmed);
      expect(copy.id, original.id);
      expect(copy.propertyId, original.propertyId);
      expect(copy.notes, original.notes);
    });

    test('can change status', () {
      final original = createSubject(status: BookingStatus.pending);
      final copy = original.copyWith(status: BookingStatus.completed);

      expect(copy.status, BookingStatus.completed);
      expect(original.status, BookingStatus.pending);
    });

    test('can change date and time', () {
      final newDate = DateTime(2025, 12, 25);
      final original = createSubject();
      final copy = original.copyWith(date: newDate, time: '09:00');

      expect(copy.date, newDate);
      expect(copy.time, '09:00');
      expect(original.date, fixedDate);
      expect(original.time, '10:00');
    });

    test('original instance is not mutated', () {
      final original = createSubject();
      original.copyWith(userName: 'Changed', status: BookingStatus.cancelled);

      expect(original.userName, 'Carlos');
      expect(original.status, BookingStatus.pending);
    });
  });
}
