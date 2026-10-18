import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

/// Abre uma conversa de WhatsApp com o número de contacto da empresa.
///
/// [message] sobrepõe-se à mensagem padrão ([AppConstants.whatsappMessage])
/// quando indicada. [phone] permite contactar um número específico (por
/// exemplo, o telefone de um cliente), adicionando o código do país quando
/// necessário.
abstract final class WhatsAppUtil {
  static Future<bool> open({String? message, String? phone}) async {
    final target = (phone == null || phone.isEmpty)
        ? AppConstants.whatsappNumber
        : phone;
    final number = normalizePhone(target);
    if (number.isEmpty) return false;
    final text = message ?? AppConstants.whatsappMessage;
    final url = Uri.parse(
      'https://wa.me/$number?text=${Uri.encodeComponent(text)}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
      return true;
    }
    return false;
  }

  /// Converte um número para o formato exigido pelo `wa.me`: apenas dígitos
  /// no formato internacional, prefixando 244 quando falta o código do país.
  static String normalizePhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 9) {
      digits = '244$digits';
    }
    return digits;
  }
}
