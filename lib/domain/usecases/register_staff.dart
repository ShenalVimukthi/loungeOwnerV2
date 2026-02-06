import '../entities/staff.dart';
import '../repositories/staff_repository.dart';
import '../../core/error/failures.dart';
import '../repositories/auth_repository.dart'; // For Either

/// Use Case: Register Staff (Driver or Conductor)
///
/// Business Rules:
/// - User ID is required
/// - Staff type must be 'driver' or 'conductor'
/// - Driver must provide license details
/// - Emergency contact is required
class RegisterStaffUseCase {
  final StaffRepository repository;

  RegisterStaffUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, Staff>> call(RegisterStaffParams params) async {
    // Business rule: Validate required fields
    if (params.userId.isEmpty) {
      return Either.left(
        const ValidationFailure('User ID is required'),
      );
    }

    if (params.staffType.isEmpty) {
      return Either.left(
        const ValidationFailure('Staff type is required'),
      );
    }

    // Business rule: Validate staff type
    if (params.staffType != 'driver' && params.staffType != 'conductor') {
      return Either.left(
        const ValidationFailure('Staff type must be driver or conductor'),
      );
    }

    // Business rule: Drivers must have license information
    if (params.staffType == 'driver') {
      if (params.licenseNumber == null || params.licenseNumber!.isEmpty) {
        return Either.left(
          const ValidationFailure('License number is required for drivers'),
        );
      }

      if (params.licenseExpiryDate == null) {
        return Either.left(
          const ValidationFailure('License expiry date is required for drivers'),
        );
      }

      // Business rule: License must not be expired
      if (params.licenseExpiryDate!.isBefore(DateTime.now())) {
        return Either.left(
          const ValidationFailure('License expiry date cannot be in the past'),
        );
      }
    }

    // Business rule: Emergency contact is required
    if (params.emergencyContact.isEmpty) {
      return Either.left(
        const ValidationFailure('Emergency contact is required'),
      );
    }

    if (params.emergencyContactName.isEmpty) {
      return Either.left(
        const ValidationFailure('Emergency contact name is required'),
      );
    }

    // Delegate to repository
    return await repository.registerStaff(
      userId: params.userId,
      staffType: params.staffType,
      licenseNumber: params.licenseNumber,
      licenseExpiryDate: params.licenseExpiryDate,
      experienceYears: params.experienceYears,
      emergencyContact: params.emergencyContact,
      emergencyContactName: params.emergencyContactName,
      busOwnerCode: params.busOwnerCode,
      busRegistrationNumber: params.busRegistrationNumber,
    );
  }
}

/// Parameters for staff registration
class RegisterStaffParams {
  final String userId;
  final String staffType;
  final String? licenseNumber;
  final DateTime? licenseExpiryDate;
  final int experienceYears;
  final String emergencyContact;
  final String emergencyContactName;
  final String? busOwnerCode;
  final String? busRegistrationNumber;

  RegisterStaffParams({
    required this.userId,
    required this.staffType,
    this.licenseNumber,
    this.licenseExpiryDate,
    this.experienceYears = 0,
    required this.emergencyContact,
    required this.emergencyContactName,
    this.busOwnerCode,
    this.busRegistrationNumber,
  });
}
