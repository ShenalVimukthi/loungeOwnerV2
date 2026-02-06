import 'package:flutter/foundation.dart';
import '../../domain/entities/staff.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/register_staff.dart';
import '../../domain/usecases/get_staff_profile.dart';

/// Presentation Layer: Staff ViewModel
///
/// Responsibilities:
/// - Manage staff-related UI state
/// - Delegate to use cases for business logic
class StaffProvider extends ChangeNotifier {
  final RegisterStaffUseCase registerStaffUseCase;
  final GetStaffProfileUseCase getStaffProfileUseCase;

  StaffProvider({
    required this.registerStaffUseCase,
    required this.getStaffProfileUseCase,
  });

  // UI State
  bool _isLoading = false;
  String? _error;
  Staff? _staff;
  User? _user;
  Map<String, dynamic>? _busOwner;
  bool _isRegistered = false;

  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  Staff? get staff => _staff;
  User? get user => _user;
  Map<String, dynamic>? get busOwner => _busOwner;
  bool get isRegistered => _isRegistered;

  // Helper getters (delegate to domain entity)
  bool get isDriver => _staff?.isDriver ?? false;
  bool get isConductor => _staff?.isConductor ?? false;
  bool get isPending => _staff?.isPending ?? false;
  bool get isActive => _staff?.isActive ?? false;
  bool get profileCompleted => _staff?.profileCompleted ?? false;
  String? get employmentStatus => _staff?.employmentStatus;
  String? get displayStatus => _staff?.displayStatus;

  /// Register new staff member
  Future<bool> registerStaff({
    required String userId,
    required String staffType,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    int experienceYears = 0,
    required String emergencyContact,
    required String emergencyContactName,
    String? busOwnerCode,
    String? busRegistrationNumber,
  }) async {
    _setLoading(true);
    _clearError();

    final params = RegisterStaffParams(
      userId: userId,
      staffType: staffType,
      licenseNumber: licenseNumber,
      licenseExpiryDate: licenseExpiryDate,
      experienceYears: experienceYears,
      emergencyContact: emergencyContact,
      emergencyContactName: emergencyContactName,
      busOwnerCode: busOwnerCode,
      busRegistrationNumber: busRegistrationNumber,
    );

    final result = await registerStaffUseCase(params);

    return result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _setLoading(false);
        return false;
      },
      (staff) {
        _staff = staff;
        _isRegistered = true;
        _setLoading(false);
        return true;
      },
    );
  }

  /// Get staff profile
  Future<bool> getStaffProfile() async {
    _setLoading(true);
    _clearError();

    final result = await getStaffProfileUseCase();

    return result.fold(
      (failure) {
        _error = _mapFailureToMessage(failure);
        _setLoading(false);
        return false;
      },
      (profile) {
        _user = profile.user;
        _staff = profile.staff;
        _busOwner = profile.busOwner;
        _isRegistered = profile.isRegistered;
        _setLoading(false);
        return true;
      },
    );
  }

  /// Clear staff data (on logout)
  void clearStaffData() {
    _staff = null;
    _user = null;
    _busOwner = null;
    _isRegistered = false;
    _error = null;
    notifyListeners();
  }

  /// Set error manually
  void setError(String error) {
    _error = error;
    notifyListeners();
  }

  /// Clear error
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
