/// Failure types for type-safe error handling
/// Part of BLoC Pro VIP Architecture
library;

import 'package:equatable/equatable.dart';

/// Base failure class cho tất cả errors trong app
/// Sử dụng sealed class để có exhaustive pattern matching
sealed class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, code, originalError];

  @override
  String toString() => '$runtimeType(message: $message, code: $code)';
}

/// Network failures - connection issues, timeout, etc.
class NetworkFailure extends Failure {
  final int? statusCode;
  final String? url;

  const NetworkFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.statusCode,
    this.url,
  });

  /// No internet connection
  factory NetworkFailure.noConnection() => const NetworkFailure(
        message: 'Không có kết nối mạng',
        code: 'NO_CONNECTION',
      );

  /// Request timeout
  factory NetworkFailure.timeout({String? url}) => NetworkFailure(
        message: 'Yêu cầu quá thời gian chờ',
        code: 'TIMEOUT',
        url: url,
      );

  /// Connection refused
  factory NetworkFailure.connectionRefused({String? url}) => NetworkFailure(
        message: 'Không thể kết nối đến máy chủ',
        code: 'CONNECTION_REFUSED',
        url: url,
      );

  @override
  List<Object?> get props => [...super.props, statusCode, url];
}

/// Server failures - 5xx errors
class ServerFailure extends Failure {
  final int? statusCode;

  const ServerFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.statusCode,
  });

  /// Internal server error (500)
  factory ServerFailure.internal() => const ServerFailure(
        message: 'Lỗi máy chủ nội bộ',
        code: 'INTERNAL_SERVER_ERROR',
        statusCode: 500,
      );

  /// Service unavailable (503)
  factory ServerFailure.unavailable() => const ServerFailure(
        message: 'Dịch vụ tạm thời không khả dụng',
        code: 'SERVICE_UNAVAILABLE',
        statusCode: 503,
      );

  /// Bad gateway (502)
  factory ServerFailure.badGateway() => const ServerFailure(
        message: 'Lỗi cổng kết nối',
        code: 'BAD_GATEWAY',
        statusCode: 502,
      );

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Client failures - 4xx errors (except validation)
class ClientFailure extends Failure {
  final int? statusCode;

  const ClientFailure({
    required super.message,
    super.code,
    super.originalError,
    super.stackTrace,
    this.statusCode,
  });

  /// Not found (404)
  factory ClientFailure.notFound({String? resource}) => ClientFailure(
        message: resource != null ? '$resource không tồn tại' : 'Không tìm thấy dữ liệu',
        code: 'NOT_FOUND',
        statusCode: 404,
      );

  /// Unauthorized (401)
  factory ClientFailure.unauthorized() => const ClientFailure(
        message: 'Phiên đăng nhập đã hết hạn',
        code: 'UNAUTHORIZED',
        statusCode: 401,
      );

  /// Forbidden (403)
  factory ClientFailure.forbidden() => const ClientFailure(
        message: 'Bạn không có quyền truy cập',
        code: 'FORBIDDEN',
        statusCode: 403,
      );

  /// Too many requests (429)
  factory ClientFailure.tooManyRequests() => const ClientFailure(
        message: 'Quá nhiều yêu cầu, vui lòng thử lại sau',
        code: 'TOO_MANY_REQUESTS',
        statusCode: 429,
      );

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Validation failures - form/input validation errors
class ValidationFailure extends Failure {
  final Map<String, List<String>> fieldErrors;

  const ValidationFailure({
    required super.message,
    super.code = 'VALIDATION_ERROR',
    super.originalError,
    super.stackTrace,
    this.fieldErrors = const {},
  });

  /// Create from server validation response
  factory ValidationFailure.fromMap(Map<String, dynamic>? errors) {
    if (errors == null || errors.isEmpty) {
      return const ValidationFailure(message: 'Dữ liệu không hợp lệ');
    }

    final Map<String, List<String>> fieldErrors = {};
    errors.forEach((key, value) {
      if (value is List) {
        fieldErrors[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        fieldErrors[key] = [value];
      }
    });

    return ValidationFailure(
      message: 'Vui lòng kiểm tra lại dữ liệu',
      fieldErrors: fieldErrors,
    );
  }

  /// Get first error for a specific field
  String? getFieldError(String fieldName) {
    final errors = fieldErrors[fieldName];
    return errors?.isNotEmpty == true ? errors!.first : null;
  }

  /// Get all errors as flat list
  List<String> get allErrors => fieldErrors.values.expand((e) => e).toList();

  /// Check if has error for specific field
  bool hasFieldError(String fieldName) => fieldErrors.containsKey(fieldName);

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Cache failures - local storage issues
class CacheFailure extends Failure {
  const CacheFailure({
    required super.message,
    super.code = 'CACHE_ERROR',
    super.originalError,
    super.stackTrace,
  });

  /// Cache read error
  factory CacheFailure.read() => const CacheFailure(
        message: 'Không thể đọc dữ liệu từ bộ nhớ cache',
        code: 'CACHE_READ_ERROR',
      );

  /// Cache write error
  factory CacheFailure.write() => const CacheFailure(
        message: 'Không thể lưu dữ liệu vào bộ nhớ cache',
        code: 'CACHE_WRITE_ERROR',
      );

  /// Cache not found
  factory CacheFailure.notFound() => const CacheFailure(
        message: 'Không tìm thấy dữ liệu trong cache',
        code: 'CACHE_NOT_FOUND',
      );

  /// Cache expired
  factory CacheFailure.expired() => const CacheFailure(
        message: 'Dữ liệu cache đã hết hạn',
        code: 'CACHE_EXPIRED',
      );
}

/// Parse/Format failures - data parsing issues
class ParseFailure extends Failure {
  final Type? expectedType;

  const ParseFailure({
    required super.message,
    super.code = 'PARSE_ERROR',
    super.originalError,
    super.stackTrace,
    this.expectedType,
  });

  /// JSON parse error
  factory ParseFailure.json({dynamic originalError}) => ParseFailure(
        message: 'Không thể phân tích dữ liệu JSON',
        code: 'JSON_PARSE_ERROR',
        originalError: originalError,
      );

  /// Type cast error
  factory ParseFailure.typeCast({Type? expectedType}) => ParseFailure(
        message: 'Kiểu dữ liệu không hợp lệ',
        code: 'TYPE_CAST_ERROR',
        expectedType: expectedType,
      );

  @override
  List<Object?> get props => [...super.props, expectedType];
}

/// Unknown/Unexpected failures
class UnknownFailure extends Failure {
  const UnknownFailure({
    super.message = 'Đã xảy ra lỗi không xác định',
    super.code = 'UNKNOWN_ERROR',
    super.originalError,
    super.stackTrace,
  });

  /// Create from exception
  factory UnknownFailure.fromException(Object exception, [StackTrace? stackTrace]) {
    return UnknownFailure(
      message: exception.toString(),
      originalError: exception,
      stackTrace: stackTrace,
    );
  }
}

/// Extension methods cho Failure
extension FailureX on Failure {
  /// Check if failure is retryable
  bool get isRetryable {
    return switch (this) {
      NetworkFailure() => true,
      ServerFailure(:final statusCode) => statusCode != 501, // Not implemented shouldn't retry
      ClientFailure(:final statusCode) => statusCode == 429, // Only retry rate limit
      _ => false,
    };
  }

  /// Check if failure is authentication related
  bool get isAuthError {
    return switch (this) {
      ClientFailure(:final statusCode) => statusCode == 401 || statusCode == 403,
      _ => false,
    };
  }

  /// Get user-friendly message
  String get userMessage => message;
}
