import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:luar_company/core/services/notification_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('NotificationPreferences', () {
    test('por omissão todas as categorias estão ativas', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = NotificationPreferences.instance;
      await prefs.load();

      for (final category in NotificationCategory.values) {
        expect(prefs.isEnabled(category), isTrue, reason: category.name);
      }
    });

    test('setEnabled persiste e recarrega o valor', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = NotificationPreferences.instance;
      await prefs.load();

      await prefs.setEnabled(NotificationCategory.promotions, false);
      expect(prefs.isEnabled(NotificationCategory.promotions), isFalse);

      // Recarrega a partir do armazenamento para confirmar persistência.
      await prefs.load();
      expect(prefs.isEnabled(NotificationCategory.promotions), isFalse);
      expect(prefs.isEnabled(NotificationCategory.messages), isTrue);
    });

    test('fromPayload mapeia categorias conhecidas e desconhecidas', () {
      expect(
        NotificationPreferences.fromPayload('messages'),
        NotificationCategory.messages,
      );
      expect(
        NotificationPreferences.fromPayload('bookings'),
        NotificationCategory.bookings,
      );
      expect(
        NotificationPreferences.fromPayload('desconhecida'),
        NotificationCategory.system,
      );
      expect(
        NotificationPreferences.fromPayload(null),
        NotificationCategory.system,
      );
    });
  });
}
