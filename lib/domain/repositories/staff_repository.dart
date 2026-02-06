import '../entities/staff.dart';
import '../entities/user.dart';
import '../../core/error/failures.dart';
import 'auth_repository.dart'; // For Either

/// Repository Interface: Staff Operations
abstract class StaffRepository {
  /// Register new staff member (driver or conductor)
  Future<Either<Failure, Staff>> registerStaff({
    required String userId,
    required String staffType,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    required int experienceYears,
    required String emergencyContact,
    required String emergencyContactName,
    String? busOwnerCode,
    String? busRegistrationNumber,
  });

  /// Get complete staff profile
  Future<Either<Failure, StaffProfile>> getStaffProfile();

  /// Update staff profile
  Future<Either<Failure, Staff>> updateStaffProfile({
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    int? experienceYears,
    String? emergencyContact,
    String? emergencyContactName,
  });
}

/// Complete staff profile with user and bus owner data
class StaffProfile {
  final User user;
  final Staff? staff;
  final Map<String, dynamic>? busOwner;

  StaffProfile({
    required this.user,
    this.staff,
    this.busOwner,
  });

  bool get isRegistered => staff != null;
}
