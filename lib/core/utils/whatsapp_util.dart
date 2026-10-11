import 'package:url_launcher/url_launcher.dart';

import '../constants/app_constants.dart';

/// Abre uma conversa de WhatsApp com o número de contacto da empresa.
///
/// [message] sobrepõe-se à mensagem padrão ([AppConstants.whatsappMessage])
/// quando indicada. [phone] permite contactar um número específico (por
/// exemplo, o telefone de um cliente), adicionando o código do país quando
/// necessário.
abstract final class WhatsAppUtil {
  static Future<bool> open({
    String? message,
    String? phone,
  }) async {
    final number = _normalizePhone(phone ?? AppConstants.whatsappNumber);
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

  static String _normalizePhone(String raw) {
    var digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 9) {
      digits = '244$digits';
    }
    return digits;
  }
}
