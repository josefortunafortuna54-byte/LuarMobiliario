import 'package:flutter_test/flutter_test.dart';
import 'package:luar_company/core/utils/whatsapp_util.dart';

void main() {
  group('WhatsAppUtil.normalizePhone', () {
    test('mantém número internacional completo', () {
      expect(WhatsAppUtil.normalizePhone('244942203497'), '244942203497');
    });

    test('remove + e espaços', () {
      expect(WhatsAppUtil.normalizePhone('+244 942 203 497'), '244942203497');
    });

    test('remove parênteses e traços', () {
      expect(WhatsAppUtil.normalizePhone('(244) 942-203-497'), '244942203497');
    });

    test('adiciona 244 a número nacional de 9 dígitos', () {
      expect(WhatsAppUtil.normalizePhone('942203497'), '244942203497');
    });

    test('adiciona 244 a número nacional com espaços', () {
      expect(WhatsAppUtil.normalizePhone('942 203 497'), '244942203497');
    });

    test('devolve vazio para valor vazio', () {
      expect(WhatsAppUtil.normalizePhone(''), '');
    });
  });
}
