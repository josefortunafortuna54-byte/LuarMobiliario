import '../../l10n/app_localizations.dart';

class Validators {
  Validators._();

  static String? required(
    String? value, {
    String? fieldName,
    AppLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      return fieldName ?? l10n?.campoObrigatorio ?? 'Campo obrigatório';
    }
    return null;
  }

  static String? email(String? value, {AppLocalizations? l10n}) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.emailObrigatorio ?? 'Email obrigatório';
    }
    final regex = RegExp(r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$');
    if (!regex.hasMatch(value.trim())) {
      return l10n?.emailInvalidoMsg ?? 'Email inválido';
    }
    return null;
  }

  static String? phone(String? value, {AppLocalizations? l10n}) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.telefoneObrigatorio ?? 'Telefone obrigatório';
    }
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 9) {
      return l10n?.telefoneInvalido ?? 'Telefone inválido';
    }
    return null;
  }

  static String? minLength(
    String? value,
    int min, {
    String? customMessage,
    AppLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      return customMessage ?? l10n?.campoObrigatorio ?? 'Campo obrigatório';
    }
    if (value.trim().length < min) {
      return customMessage ??
          l10n?.minimoCaracteres(min) ??
          'Mínimo de $min caracteres';
    }
    return null;
  }

  static String? maxLength(
    String? value,
    int max, {
    String? customMessage,
    AppLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) return null;
    if (value.trim().length > max) {
      return customMessage ??
          l10n?.maximoCaracteres(max) ??
          'Máximo de $max caracteres';
    }
    return null;
  }

  static String? numeric(String? value, {AppLocalizations? l10n}) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.campoObrigatorio ?? 'Campo obrigatório';
    }
    final cleaned = value.replaceAll(RegExp(r'[,.\s]'), '');
    if (double.tryParse(cleaned) == null) {
      return l10n?.numeroInvalido ?? 'Número inválido';
    }
    return null;
  }

  static String? match(
    String? value,
    String pattern, {
    String? customMessage,
    AppLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.campoObrigatorio ?? 'Campo obrigatório';
    }
    final regex = RegExp(pattern);
    if (!regex.hasMatch(value.trim())) {
      return customMessage ?? l10n?.formatoInvalido ?? 'Formato inválido';
    }
    return null;
  }
}
