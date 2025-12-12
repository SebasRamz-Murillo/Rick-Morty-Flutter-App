import 'package:equatable/equatable.dart';

/// Clase base para manejar errores de forma tipada en la app.
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Error de servidor (500, respuestas inválidas, etc.)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Error del servidor']);
}

/// Error de red (sin conexión, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Sin conexión a internet']);
}

/// Error de caché local (Hive)
class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Error de caché local']);
}

/// Recurso no encontrado (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Recurso no encontrado']);
}
