/// Base class for all failures in the app
/// Failures represent domain-level errors
abstract class Failure {
  final String message;
  final String? code;

  const Failure(this.message, [this.code]);

  @override
  String toString() =>
      'Failure: $message${code != null ? ' (Code: $code)' : ''}';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Failure && other.message == message && other.code == code;
  }

  @override
  int get hashCode => message.hashCode ^ code.hashCode;
}

/// Server-related failures
class ServerFailure extends Failure {
  const ServerFailure(super.message, [super.code]);
}

/// Network-related failures
class NetworkFailure extends Failure {
  const NetworkFailure(super.message, [super.code]);
}

/// Authentication failures
class AuthFailure extends Failure {
  const AuthFailure(super.message, [super.code]);
}

/// Validation failures
class ValidationFailure extends Failure {
  const ValidationFailure(super.message, [super.code]);
}

/// Cache/Storage failures
class CacheFailure extends Failure {
  const CacheFailure(super.message, [super.code]);
}

/// Rate limit failures
class RateLimitFailure extends Failure {
  final DateTime? retryAfter;

  const RateLimitFailure(super.message, [super.code, this.retryAfter]);
}

/// OTP-specific failures
class OTPFailure extends Failure {
  const OTPFailure(super.message, [super.code]);
}

/// Staff registration failures
class StaffRegistrationFailure extends Failure {
  const StaffRegistrationFailure(super.message, [super.code]);
}

/// OCR processing failures
class OCRFailure extends Failure {
  const OCRFailure(super.message, [super.code]);
}

/// File upload failures
class FileUploadFailure extends Failure {
  const FileUploadFailure(super.message, [super.code]);
}

/// Generic/Unknown failures
class UnknownFailure extends Failure {
  const UnknownFailure(super.message, [super.code]);
}
