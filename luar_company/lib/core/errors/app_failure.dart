/// Classificação de falhas da aplicação.
sealed class Failure {
  const Failure(this.message);

  final String message;
}

/// Erro genérico de rede.
class NetworkFailure extends Failure {
  const NetworkFailure(super.message);
}

/// Erro de autenticação/autorização.
class AuthFailure extends Failure {
  const AuthFailure(super.message);
}

/// Erro de validação de dados.
class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

/// Erro de servidor/Backend.
class ServerFailure extends Failure {
  const ServerFailure(super.message);
}

/// Erro desconhecido ou inesperado.
class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}

/// Erro de armazenamento/ficheiros.
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}
