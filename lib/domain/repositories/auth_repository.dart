import '../entities/user.dart';
import '../entities/auth_tokens.dart';
import '../../core/error/failures.dart';

/// Repository Interface: Authentication
/// This defines the contract that data layer must implement
/// Domain layer doesn't care HOW data is fetched, just WHAT data is needed
abstract class AuthRepository {
  /// Send OTP to phone number
  /// Returns Right(void) on success or Left(Failure) on error
  Future<Either<Failure, void>> sendOtp(String phoneNumber);

  /// Verify OTP and authenticate user
  /// Returns Right(AuthResult) on success or Left(Failure) on error
  Future<Either<Failure, AuthResult>> verifyOtp({
    required String phoneNumber,
    required String otp,
  });

  /// Verify OTP - Generic endpoint (no role assignment)
  /// For multi-role flows (lounge owner + staff selection)
  /// Returns Right(AuthResult) on success or Left(Failure) on error
  Future<Either<Failure, AuthResult>> verifyOtpGeneric({
    required String phoneNumber,
    required String otp,
  });

  /// Verify OTP for Lounge Owner
  /// Returns Right(AuthResult) on success or Left(Failure) on error
  Future<Either<Failure, AuthResult>> verifyOtpLoungeOwner({
    required String phoneNumber,
    required String otp,
  });

  /// Verify OTP for Lounge Staff
  /// Returns Right(AuthResult) on success or Left(Failure) on error
  Future<Either<Failure, AuthResult>> verifyOtpLoungeStaff({
    required String phoneNumber,
    required String otp,
    required String loungeId,
    required String fullName,
    required String nicNumber,
    required String email,
  });

  /// Verify OTP for Registered Lounge Staff
  /// Returns Right(AuthResult) on success or Left(Failure) on error
  Future<Either<Failure, AuthResult>> verifyOtpLoungeStaffRegistered({
    required String phoneNumber,
    required String otp,
  });

  /// Refresh access token
  /// Returns Right(AuthTokens) on success or Left(Failure) on error
  Future<Either<Failure, AuthTokens>> refreshToken();

  /// Logout user
  /// Returns Right(void) on success or Left(Failure) on error
  Future<Either<Failure, void>> logout({bool logoutAll = false});

  /// Update user profile in local storage
  /// Returns Right(User) on success or Left(Failure) on error
  Future<Either<Failure, User>> updateUserProfile(User user);

  /// Check if user is authenticated
  Future<bool> isAuthenticated();

  /// Get current user from local storage
  Future<User?> getCurrentUser();
}

/// Result of authentication containing user and tokens
class AuthResult {
  final User user;
  final AuthTokens tokens;
  final List<String> roles;
  final bool isNewUser;
  final String?
      registrationStep; // For lounge owners: phone_verified, personal_info, nic_uploaded, lounge_added, completed

  AuthResult({
    required this.user,
    required this.tokens,
    required this.roles,
    required this.isNewUser,
    this.registrationStep,
  });
}

/// Either type for functional error handling
/// This will be replaced with dartz package in future
class Either<L, R> {
  final L? _left;
  final R? _right;

  Either.left(L left)
      : _left = left,
        _right = null;

  Either.right(R right)
      : _left = null,
        _right = right;

  bool get isLeft => _left != null;
  bool get isRight => _right != null;

  L get left {
    if (_left == null) throw StateError('Called left on Right');
    return _left as L;
  }

  R get right {
    if (_right == null) throw StateError('Called right on Left');
    return _right as R;
  }

  T fold<T>(T Function(L) onLeft, T Function(R) onRight) {
    if (_left != null) return onLeft(_left as L);
    return onRight(_right as R);
  }
}
