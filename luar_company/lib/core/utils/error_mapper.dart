import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../errors/app_failure.dart';

abstract final class ErrorMapper {
  /// Mapeia exceções para uma [Failure] amigável ao utilizador.
  static Failure map(Object error, [StackTrace? stackTrace]) {
    if (error is AuthException) {
      return AuthFailure(
        error.message.isEmpty ? 'Erro de autenticação' : error.message,
      );
    }
    if (error is PostgrestException) {
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
