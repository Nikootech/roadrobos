import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';

// ─── AppError sealed class ───────────────────────────────────────────────────

sealed class AppError implements Exception {
  final String message;
  const AppError(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

class NetworkError extends AppError {
  final int? statusCode;
  const NetworkError(super.message, {this.statusCode});
}

class AuthError extends AppError {
  const AuthError(super.message);
}

class DatabaseError extends AppError {
  const DatabaseError(super.message);
}

class ValidationError extends AppError {
  final Map<String, String> fieldErrors;
  const ValidationError(super.message, {this.fieldErrors = const {}});
}

class PaymentError extends AppError {
  const PaymentError(super.message);
}

// ─── Result<T> type ──────────────────────────────────────────────────────────

typedef Result<T> = ({T? data, AppError? error});

extension ResultX<T> on Result<T> {
  bool get isSuccess => error == null;
  bool get isFailure => error != null;
  T get requireData => data!;
}

// ─── Interceptors ─────────────────────────────────────────────────────────────

class AuthInterceptor extends Interceptor {
  final Future<String?> Function() getToken;
  const AuthInterceptor(this.getToken);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

class RetryInterceptor extends Interceptor {
  static const int _maxRetries = 3;
  static const Duration _base = Duration(milliseconds: 400);

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final attempt = (err.requestOptions.extra['_retry'] as int?) ?? 0;
    final isRetryable = err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout ||
        err.type == DioExceptionType.connectionError ||
        err.response?.statusCode == 503;

    if (isRetryable && attempt < _maxRetries) {
      // Exponential backoff with jitter
      final delay =
          _base * (1 << attempt) + Duration(milliseconds: attempt * 30);
      await Future.delayed(delay);
      err.requestOptions.extra['_retry'] = attempt + 1;
      try {
        final cloned = await Dio().fetch<dynamic>(err.requestOptions);
        return handler.resolve(cloned);
      } on DioException catch (e) {
        return handler.next(e);
      }
    }
    handler.next(err);
  }
}

class _RedactingLoggerInterceptor extends Interceptor {
  static const _redactKeys = {
    'authorization',
    'token',
    'access_token',
    'refresh_token',
    'razorpay_payment_id',
    'password',
    'email',
    'phone',
    'fcm_token',
    'apikey',
    'x-api-key',
  };

  Map<String, dynamic> _redact(Map<String, dynamic> map) {
    return map.map((k, v) {
      final lower = k.toLowerCase();
      if (_redactKeys.contains(lower)) return MapEntry(k, '[REDACTED]');
      return MapEntry(k, v);
    });
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    debugPrint('[DIO →] ${options.method} ${options.uri}');
    debugPrint('[DIO → headers] ${_redact(options.headers)}');
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    debugPrint('[DIO ←] ${response.statusCode} ${response.requestOptions.uri}');
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    debugPrint('[DIO ✗] ${err.response?.statusCode} ${err.requestOptions.uri}');
    handler.next(err);
  }
}

class ErrorMappingInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final AppError appError;
    switch (err.response?.statusCode) {
      case 400:
        appError = const ValidationError('Invalid request data.');
      case 401:
        appError = const AuthError('Session expired. Please log in again.');
      case 403:
        appError =
            const AuthError('You do not have permission for this action.');
      case 422:
        appError =
            const ValidationError('Unprocessable data — check your inputs.');
      case 429:
        appError = const NetworkError('Too many requests. Please slow down.',
            statusCode: 429);
      case 503:
        appError = const NetworkError('Service temporarily unavailable.',
            statusCode: 503);
      default:
        appError = NetworkError(
          err.message ?? 'An unexpected network error occurred.',
          statusCode: err.response?.statusCode,
        );
    }
    handler.reject(DioException(
      requestOptions: err.requestOptions,
      error: appError,
      type: err.type,
      response: err.response,
    ));
  }
}

// ─── DioClient factory ────────────────────────────────────────────────────────

class DioClient {
  /// Creates a production-ready Dio instance with all 4 interceptors wired.
  static Dio create({
    required String baseUrl,
    required Future<String?> Function() getToken,
    Duration connectTimeout = const Duration(seconds: 10),
    Duration receiveTimeout = const Duration(seconds: 15),
    Map<String, String> extraHeaders = const {},
  }) {
    final dio = Dio(BaseOptions(
      baseUrl: baseUrl,
      connectTimeout: connectTimeout,
      receiveTimeout: receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        ...extraHeaders,
      },
    ));

    dio.interceptors.addAll([
      AuthInterceptor(getToken),
      RetryInterceptor(),
      if (kDebugMode) _RedactingLoggerInterceptor(),
      ErrorMappingInterceptor(),
    ]);

    return dio;
  }
}
