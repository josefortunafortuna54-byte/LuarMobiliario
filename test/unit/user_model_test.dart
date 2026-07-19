import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/models/user_model.dart';

void main() {
  final now = DateTime(2025, 6, 15, 10, 30);
  final later = DateTime(2025, 7, 1);

  UserModel createSubject({
    String id = 'u1',
    String name = 'João Silva',
    String email = 'joao@test.com',
    String phone = '+244923456789',
    String avatarUrl = 'https://example.com/avatar.jpg',
    UserRole role = UserRole.client,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id,
      name: name,
      email: email,
      phone: phone,
      avatarUrl: avatarUrl,
      role: role,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? later,
    );
  }

  group('UserRole', () {
    test('has three values: client, agent, admin', () {
      expect(UserRole.values.length, 3);
      expect(UserRole.values, contains(UserRole.client));
      expect(UserRole.values, contains(UserRole.agent));
      expect(UserRole.values, contains(UserRole.admin));
    });
  });

  group('UserModel constructor', () {
    test('creates instance with all required fields', () {
      final user = createSubject();
      expect(user.id, 'u1');
      expect(user.name, 'João Silva');
      expect(user.email, 'joao@test.com');
      expect(user.phone, '+244923456789');
      expect(user.avatarUrl, 'https://example.com/avatar.jpg');
      expect(user.role, UserRole.client);
      expect(user.createdAt, now);
      expect(user.updatedAt, later);
    });
  });

  group('fromJson', () {
    test('parses a complete JSON map', () {
      final json = {
        'id': 'u2',
        'name': 'Maria',
        'email': 'maria@test.com',
        'phone': '+244912345678',
        'avatar_url': 'https://example.com/maria.jpg',
        'role': 'agent',
        'created_at': '2025-01-10T08:00:00.000',
        'updated_at': '2025-03-20T12:00:00.000',
      };

      final user = UserModel.fromJson(json);

      expect(user.id, 'u2');
      expect(user.name, 'Maria');
      expect(user.email, 'maria@test.com');
      expect(user.phone, '+244912345678');
      expect(user.avatarUrl, 'https://example.com/maria.jpg');
      expect(user.role, UserRole.agent);
      expect(user.createdAt, DateTime(2025, 1, 10, 8, 0));
      expect(user.updatedAt, DateTime(2025, 3, 20, 12, 0));
    });

    test('defaults to client role for unknown role string', () {
      final json = {
        'id': 'u3',
        'role': 'unknown_role',
      };

      final user = UserModel.fromJson(json);
      expect(user.role, UserRole.client);
    });

    test('defaults to client role when role is null', () {
      final json = <String, dynamic>{
        'id': 'u4',
        'role': null,
      };

      final user = UserModel.fromJson(json);
      expect(user.role, UserRole.client);
    });

    test('handles all valid role strings', () {
      expect(
        UserModel.fromJson({'role': 'client'}).role,
        UserRole.client,
      );
      expect(
        UserModel.fromJson({'role': 'agent'}).role,
        UserRole.agent,
      );
      expect(
        UserModel.fromJson({'role': 'admin'}).role,
        UserRole.admin,
      );
    });

    test('fills empty strings for missing string fields', () {
      final user = UserModel.fromJson(<String, dynamic>{});
      expect(user.id, '');
      expect(user.name, '');
      expect(user.email, '');
      expect(user.phone, '');
      expect(user.avatarUrl, '');
    });

    test('uses DateTime.now() for missing date fields', () {
      final before = DateTime.now();
      final user = UserModel.fromJson(<String, dynamic>{});
      final after = DateTime.now();

      expect(user.createdAt.isAfter(before), isTrue);
      expect(user.createdAt.isBefore(after), isTrue);
      expect(user.updatedAt.isAfter(before), isTrue);
      expect(user.updatedAt.isBefore(after), isTrue);
    });
  });

  group('toJson', () {
    test('serializes all fields correctly', () {
      final user = createSubject(
        role: UserRole.admin,
        createdAt: DateTime(2025, 1, 1),
        updatedAt: DateTime(2025, 6, 15),
      );

      final json = user.toJson();

      expect(json['id'], 'u1');
      expect(json['name'], 'João Silva');
      expect(json['email'], 'joao@test.com');
      expect(json['phone'], '+244923456789');
      expect(json['avatar_url'], 'https://example.com/avatar.jpg');
      expect(json['role'], 'admin');
      expect(json['created_at'], '2025-01-01T00:00:00.000');
      expect(json['updated_at'], '2025-06-15T00:00:00.000');
    });

    test('uses snake_case keys matching API format', () {
      final json = createSubject().toJson();
      expect(json.containsKey('avatar_url'), isTrue);
      expect(json.containsKey('created_at'), isTrue);
      expect(json.containsKey('updated_at'), isTrue);
      expect(json.containsKey('camelCase'), isFalse);
    });
  });

  group('fromJson ↔ toJson round trip', () {
    test('fromJson(toJson()) preserves all values', () {
      final original = createSubject(
        id: 'rt1',
        name: 'Round Trip',
        email: 'rt@test.com',
        phone: '+244999999999',
        avatarUrl: 'https://example.com/rt.jpg',
        role: UserRole.agent,
        createdAt: DateTime(2024, 12, 25, 8, 30),
        updatedAt: DateTime(2025, 6, 1, 16, 0),
      );

      final restored = UserModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.email, original.email);
      expect(restored.phone, original.phone);
      expect(restored.avatarUrl, original.avatarUrl);
      expect(restored.role, original.role);
      expect(restored.createdAt, original.createdAt);
      expect(restored.updatedAt, original.updatedAt);
    });

    test('toJson produces 8 keys', () {
      final json = createSubject().toJson();
      expect(json.length, 8);
    });
  });

  group('copyWith', () {
    test('returns identical instance when no arguments provided', () {
      final original = createSubject();
      final copy = original.copyWith();

      expect(copy.id, original.id);
      expect(copy.name, original.name);
      expect(copy.email, original.email);
      expect(copy.phone, original.phone);
      expect(copy.avatarUrl, original.avatarUrl);
      expect(copy.role, original.role);
      expect(copy.createdAt, original.createdAt);
      expect(copy.updatedAt, original.updatedAt);
    });

    test('overrides only specified fields', () {
      final original = createSubject();
      final copy = original.copyWith(name: 'Novo Nome');

      expect(copy.name, 'Novo Nome');
      expect(copy.id, original.id);
      expect(copy.email, original.email);
      expect(copy.role, original.role);
    });

    test('can change role', () {
      final original = createSubject(role: UserRole.client);
      final copy = original.copyWith(role: UserRole.admin);

      expect(copy.role, UserRole.admin);
      expect(original.role, UserRole.client);
    });

    test('can change multiple fields at once', () {
      final original = createSubject();
      final copy = original.copyWith(
        name: 'Updated',
        email: 'new@test.com',
        role: UserRole.agent,
      );

      expect(copy.name, 'Updated');
      expect(copy.email, 'new@test.com');
      expect(copy.role, UserRole.agent);
      expect(copy.id, original.id);
      expect(copy.phone, original.phone);
    });

    test('original instance is not mutated', () {
      final original = createSubject();
      original.copyWith(name: 'Changed');

      expect(original.name, 'João Silva');
    });
  });
}
