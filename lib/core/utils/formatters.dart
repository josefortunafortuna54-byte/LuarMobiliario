String formatPrice(double value) {
  final buffer = StringBuffer('AOA ');
  final text = value.toStringAsFixed(0);
  var count = 0;

  for (var i = text.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buffer.write('.');
    buffer.write(text[i]);
    count++;
  }

  return buffer.toString().split('').reversed.join();
}

String formatDate(DateTime date) {
  final day = date.day.toString().padLeft(2, '0');
  final month = date.month.toString().padLeft(2, '0');
  final year = date.year.toString().padLeft(4, '0');
  return '$day/$month/$year';
}

String formatDateTime(DateTime dateTime) {
  final date = formatDate(dateTime);
  final hour = dateTime.hour.toString().padLeft(2, '0');
  final minute = dateTime.minute.toString().padLeft(2, '0');
  return '$date $hour:$minute';
}

String formatArea(double area) {
  return '${area.toStringAsFixed(0)} m\u00B2';
}

String formatPhone(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  if (digits.length < 9) return phone;

  final country = digits.startsWith('244') ? '+244' : '+244';
  final local = digits.length >= 12
      ? digits.substring(digits.length - 9)
      : digits.length >= 9
          ? digits.substring(digits.length - 9)
          : digits;

  final p1 = local.substring(0, 3);
  final p2 = local.substring(3, 6);
  final p3 = local.substring(6, 9);

  return '$country $p1 $p2 $p3';
}

String truncateText(String text, int maxLength) {
  if (text.length <= maxLength) return text;
  return '${text.substring(0, maxLength).trimRight()}...';
}
