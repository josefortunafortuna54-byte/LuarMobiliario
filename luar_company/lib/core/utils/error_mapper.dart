import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_failure.dart';

abstract final class ErrorMapper {
  /// Códigos Postgres/PostgREST que indicam recusa por política RLS ou por
  /// falta de autorização.
  ///
  /// - `42501`: `insufficient_privilege` (Postgres)
  /// - `PGRST301`: a política RLS bloqueou a operação (PostgREST)
  static const Set<String> _permissionErrorCodes = {'42501', 'PGRST301'};

  /// Padrões das mensagens devolvidas pelo Postgres quando uma política
  /// row-level security recusa a operação.
  static const List<String> _permissionMessagePatterns = [
    'row-level security',
    'row level security',
    'permission denied',
    'not authorized',
    'não autorizado',
    'permissão negada',
  ];

  /// Indica se a falha corresponde a uma violação de permissões (RLS).
  ///
  /// A detecção é feita por código de erro e por mensagem, porque a versão
  /// do `postgrest` em uso não expõe o status HTTP na exceção.
  static bool isPermissionError(Object error) {
    if (error is PostgrestException) {
      final code = error.code?.trim() ?? '';
      if (_permissionErrorCodes.contains(code)) return true;

      final message = error.message.toLowerCase();
      return _permissionMessagePatterns.any(message.contains);
    }
    if (error is AuthException) {
      final message = error.message.toLowerCase();
      return message.contains('not authorized') ||
          message.contains('não autorizado');
    }
    return false;
  }

  /// Mapeia exceções para uma [Failure] amigável ao utilizador.
  static Failure map(Object error, [StackTrace? stackTrace]) {
    if (error is AuthException) {
      return AuthFailure(
        error.message.isEmpty ? 'Erro de autenticação' : error.message,
      );
    }
    if (error is PostgrestException) {
      if (isPermissionError(error)) {
        return const PermissionFailure(
          'Sem permissão para esta operação. Contacte o administrador.',
        );
      }
      return ServerFailure(
        error.message.isEmpty ? 'Erro no servidor' : error.message,
      );
    }
    if (error is StorageException) {
      return StorageFailure(
        error.message.isEmpty ? 'Erro ao armazenar ficheiro' : error.message,
      );
    }
    if (error is FormatException) {
      return const ValidationFailure('Dados inválidos');
    }
    if (error is StateError) {
      return ValidationFailure(error.message);
    }
    if (error is TimeoutException) {
      return const NetworkFailure('Tempo de espera excedido');
    }
    if (error is SocketException) {
      return const NetworkFailure('Sem ligação à internet');
    }
    if (error.toString().contains('network') ||
        error.toString().contains('connection') ||
        error.toString().contains('internet')) {
      return const NetworkFailure('Verifique a sua ligação à internet');
    }

    final message = error.toString();
    if (message.isEmpty) {
      return const UnknownFailure('Ocorreu um erro inesperado');
    }

    return message.length > 120
        ? const UnknownFailure('Ocorreu um erro inesperado')
        : UnknownFailure(message);
  }

  /// Obtém mensagem amigável para apresentação na UI.
  static String toMessage(Object error, [StackTrace? stackTrace]) {
    return map(error, stackTrace).message;
  }
}
