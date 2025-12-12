import 'package:dio/dio.dart';
import 'package:rick_and_morty/core/utils/constants.dart';
import 'package:rick_and_morty/core/error/failures.dart';

/// Cliente HTTP centralizado con Dio.
/// Configura base URL, timeouts, headers e interceptores.
class DioClient {
  late final Dio _dio;

  DioClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Log de requests/responses en debug
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestBody: true,
      responseBody: true,
      error: true,
    ));

    // Manejo centralizado de errores
    _dio.interceptors.add(_ErrorInterceptor());
  }

  Dio get dio => _dio;

  /// Realiza una petición GET al [path] con [queryParameters] opcionales.
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }
}

/// Interceptor que convierte [DioException] en [Failure] tipados.
class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final failure = _handleError(err);
    handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        error: failure,
        type: err.type,
        response: err.response,
      ),
    );
  }

  /// Mapea el tipo de error Dio a un [Failure] específico.
  Failure _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure('Tiempo de conexión agotado');

      case DioExceptionType.connectionError:
        return const NetworkFailure();

      case DioExceptionType.badResponse:
        return _handleBadResponse(error.response?.statusCode);

      case DioExceptionType.cancel:
        return const ServerFailure('Petición cancelada');

      default:
        return const ServerFailure();
    }
  }

  /// Mapea códigos HTTP a [Failure] específicos.
  Failure _handleBadResponse(int? statusCode) {
    switch (statusCode) {
      case 400:
        return const ServerFailure('Petición inválida');
      case 404:
        return const NotFoundFailure();
      case 500:
        return const ServerFailure('Error interno del servidor');
      default:
        return const ServerFailure();
    }
  }
}
