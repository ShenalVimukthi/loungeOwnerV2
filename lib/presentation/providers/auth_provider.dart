import 'package:flutter/foundation.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/send_otp.dart';
import '../../domain/usecases/verify_otp.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/repositories/auth_repository.dart';

/// Presentation Layer: Auth ViewModel
///
/// Responsibilities:
/// - Manage UI state only
/// - Delegate business logic to use cases
/// - Convert domain failures to UI-friendly messages
class AuthProvider extends ChangeNotifier {
  final SendOtpUseCase sendOtpUseCase;
  final VerifyOtpUseCase verifyOtpUseCase;
  final LogoutUseCase logoutUseCase;
  final AuthRepository authRepository;

  AuthProvider({
    required this.sendOtpUseCase,
    required this.verifyOtpUseCase,
    required this.logoutUseCase,
    required this.authRepository,
  });

  // UI State
  bool _isLoading = false;
  String? _error;
  User? _user;
  String? _phoneNumber;
  bool _isAuthenticated = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;
  String? get phoneNumber => _phoneNumber;
  bool get isAuthenticated => _isAuthenticated;

  /// Check authentication status on app start
  Future<void> checkAuthStatus() async {
    _setLoading(true);
    _clearError();

    try {
      _isAuthenticated = await authRepository.isAuthenticated();

      if (_isAuthenticated) {
        _user = await authRepository.getCurrentUser();
      } else {
        _user = null;
      }
    } catch (e) {
      _error = 'Failed to check authentication status';
      _isAuthenticated = false;
      _user = null;
    } finally {
      _setLoading(false);
    }
  }

  /// Send OTP to phone number
  Future<bool> sendOtp(String phoneNumber) async {
    _setLoading(true);
    _clearError();
    _phoneNumber = phoneNumber;

    final result = await sendOtpUseCase(phoneNumber);

    return result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _setLoading(false);
        return false;
      },
      (_) {
        _setLoading(false);
        return true;
      },
    );
  }

  /// Verify OTP and authenticate
  /// Returns Map with navigation info
  Future<Map<String, dynamic>> verifyOtp(String phoneNumber, String otp) async {
    _setLoading(true);
    _clearError();

    final result = await verifyOtpUseCase(phoneNumber: phoneNumber, otp: otp);

    return result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _setLoading(false);
        return {'success': false, 'nextRoute': '/otp-verification'};
      },
      (verifyResult) {
        // Update UI state
        _isAuthenticated = true;
        _phoneNumber = null;

        // Get user from repository (already saved by repository)
        authRepository.getCurrentUser().then((user) {
          _user = user;
          notifyListeners();
        });

        _setLoading(false);

        return {
          'success': true,
          'userId': verifyResult.userId,
          'roles': verifyResult.roles,
          'nextRoute': verifyResult.nextRoute,
          'registrationStep': verifyResult.registrationStep,
          'isNewUser': verifyResult.isNewUser,
          'profileCompleted': verifyResult.profileCompleted,
        };
      },
    );
  }

  /// Logout user
  Future<bool> logout({bool logoutAll = false}) async {
    _setLoading(true);
    _clearError();

    final result = await logoutUseCase(logoutAll: logoutAll);

    return result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        // Still clear local state
        _isAuthenticated = false;
        _user = null;
        _phoneNumber = null;
        _setLoading(false);
        return true; // Return true since local logout succeeded
      },
      (_) {
        _isAuthenticated = false;
        _user = null;
        _phoneNumber = null;
        _setLoading(false);
        return true;
      },
    );
  }

  /// Update user data (when profile changes)
  void updateUser(User user) {
    _user = user;
    notifyListeners();
  }

  /// Update user profile and save to storage
  Future<bool> updateUserProfile(User user) async {
    _setLoading(true);
    _clearError();

    final result = await authRepository.updateUserProfile(user);

    return result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _setLoading(false);
        return false;
      },
      (updatedUser) {
        _user = updatedUser;
        _setLoading(false);
        return true;
      },
    );
  }

  /// Clear error message
  void clearError() {
    _clearError();
  }

  // Private helpers
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  /// Map domain failures to user-friendly messages
  String _mapFailureToMessage(dynamic failure) {
    return failure.toString().replaceFirst('Failure: ', '');
  }
}
