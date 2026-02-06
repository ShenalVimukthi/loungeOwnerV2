/// Base class for all exceptions in the app
/// Exceptions represent data-layer errors (API, cache, etc.)
abstract class AppException implements Exception {
  final String message;
  final String? code;

  const AppException(this.message, [this.code]);

  @override
  String toString() =>
      'Exception: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Server/API exceptions
class ServerException extends AppException {
  final int? statusCode;

  const ServerException(super.message, [super.code, this.statusCode]);
}

/// Network exceptions (no internet, timeout, etc.)
class NetworkException extends AppException {
  const NetworkException(super.message, [super.code]);
}

/// Cache exceptions
class CacheException extends AppException {
  const CacheException(super.message, [super.code]);
}

/// Authentication exceptions
class AuthException extends AppException {
  const AuthException(super.message, [super.code]);
}

/// Validation exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, [super.code]);
}

/// File upload exceptions
class FileUploadException extends AppException {
  const FileUploadException(super.message, [super.code]);
}
