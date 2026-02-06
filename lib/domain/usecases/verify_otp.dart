import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';

/// Use Case: Verify OTP
///
/// Business Rules:
/// - Phone number must be valid
/// - OTP must be 6 digits
/// - Multi-role support: Passengers CAN become drivers/conductors
/// - Route based on staff roles (driver/conductor), not passenger role
class VerifyOtpUseCase {
  final AuthRepository repository;

  VerifyOtpUseCase(this.repository);

  /// Execute the use case
  ///
  /// Returns:
  /// - Right(VerifyOtpResult) on success
  /// - Left(Failure) on error
  Future<Either<Failure, VerifyOtpResult>> call({
    required String phoneNumber,
    required String otp,
  }) async {
    // Business rule: Validate inputs
    if (phoneNumber.isEmpty) {
      return Either.left(
        const ValidationFailure('Phone number cannot be empty'),
      );
    }

    if (otp.isEmpty) {
      return Either.left(
        const ValidationFailure('OTP cannot be empty'),
      );
    }

    if (otp.length != 6) {
      return Either.left(
        const ValidationFailure('OTP must be 6 digits'),
      );
    }

    // Delegate to repository
    final result = await repository.verifyOtp(
      phoneNumber: phoneNumber,
      otp: otp,
    );

    // Business rule: Multi-role system - check for STAFF roles (driver/conductor)
    // Passengers are ALLOWED to add staff roles
    return result.fold(
      (failure) => Either.left(failure),
      (authResult) {
        // No blocking based on passenger role!
        // Multi-role system: Users can be both passenger AND driver/conductor

        // Success - return result with appropriate routing
        return Either.right(
          VerifyOtpResult(
            userId: authResult.user.id,
            roles: authResult.roles,
            nextRoute: _determineNextRoute(authResult),
            registrationStep: authResult.registrationStep,
            isNewUser: authResult.isNewUser,
            profileCompleted: authResult.user.profileCompleted,
          ),
        );
      },
    );
  }

  /// Business logic: Determine next route based on user state
  String _determineNextRoute(AuthResult authResult) {
    // Check registration step instead of role presence
    // All new lounge owners get the lounge_owner role immediately,
    // but registration_step determines if they've completed registration
    final registrationStep = authResult.registrationStep;
    
    // If no registration_step or step is not 'completed', show registration
    if (registrationStep == null || 
        registrationStep.isEmpty || 
        registrationStep == 'phone_verified' ||
        registrationStep == 'personal_info' ||
        registrationStep == 'nic_uploaded' ||
        registrationStep == 'lounge_added') {
      // User hasn't completed registration → show registration forms
      return 'lounge-owner-registration';
    }

    // Registration completed → go to home/dashboard
    return 'lounge-owner-home';
  }
}

/// Result of OTP verification
class VerifyOtpResult {
  final String userId;
  final List<String> roles;
  final String nextRoute;
  final String? registrationStep; // For lounge owners: phone_verified, personal_info, nic_uploaded, lounge_added, completed
  final bool isNewUser;
  final bool profileCompleted;

  VerifyOtpResult({
    required this.userId,
    required this.roles,
    required this.nextRoute,
    this.registrationStep,
    required this.isNewUser,
    required this.profileCompleted,
  });
}
