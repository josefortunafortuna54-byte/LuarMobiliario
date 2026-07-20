class Validators {
  Validators._();

  static String? required(
    String? value, {
    String fieldName = 'Campo obrigatório',
  }) {
    if (value == null || value.trim().isEmpty) return fieldName;
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) return 'Email obrigatório';
    final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) return 'Email inválido';
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.trim().isEmpty) return 'Telefone obrigatório';
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) return 'Telefone inválido';
    return null;
  }

  static String? minLength(String? value, int min, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? 'Campo obrigatório';
    }
    if (value.trim().length < min) {
      return customMessage ?? 'Mínimo de $min caracteres';
    }
    return null;
  }

  static String? maxLength(String? value, int max, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > max) {
      return customMessage ?? 'Máximo de $max caracteres';
    }
    return null;
  }

  static String? numeric(String? value) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    final cleaned = value.replaceAll(RegExp(r'[,.\s]'), '');
    if (double.tryParse(cleaned) == null) return 'Número inválido';
    return null;
  }

  static String? match(String? value, String pattern, {String? customMessage}) {
    if (value == null || value.trim().isEmpty) return 'Campo obrigatório';
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value.trim())) {
      return customMessage ?? 'Formato inválido';
    }
    return null;
  }
}
