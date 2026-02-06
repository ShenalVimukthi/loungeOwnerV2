import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';

/// Use Case: Send OTP
///
/// Business Rules:
/// - Phone number must be valid
/// - Rate limiting applies (handled by repository)
class SendOtpUseCase {
  final AuthRepository repository;

  SendOtpUseCase(this.repository);

  /// Execute the use case
  ///
  /// Returns:
  /// - Right(void) on success
  /// - Left(Failure) on error
  Future<Either<Failure, void>> call(String phoneNumber) async {
    // Business rule: Phone number validation
    if (phoneNumber.isEmpty) {
      return Either.left(
        const ValidationFailure('Phone number cannot be empty'),
      );
    }

    // Delegate to repository
    return await repository.sendOtp(phoneNumber);
  }
}
