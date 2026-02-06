import '../../domain/entities/staff.dart';

/// Data Model: Staff
/// Handles JSON serialization/deserialization for staff data
class StaffModel extends Staff {
  StaffModel({
    required super.id,
    required super.userId,
    super.busOwnerId,
    required super.staffType,
    super.licenseNumber,
    super.licenseExpiryDate,
    required super.experienceYears,
    super.emergencyContact,
    super.emergencyContactName,
    required super.employmentStatus,
    required super.profileCompleted,
    super.createdAt,
    super.hireDate,
    super.totalTripsCompleted,
    super.performanceRating,
  });

  /// Create StaffModel from JSON
  factory StaffModel.fromJson(Map<String, dynamic> json) {
    return StaffModel(
      id: json['id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      busOwnerId: json['bus_owner_id'] as String?,
      staffType: json['staff_type'] as String? ?? 'driver',
      licenseNumber: json['license_number'] as String?,
      licenseExpiryDate: json['license_expiry_date'] != null
          ? DateTime.parse(json['license_expiry_date'] as String)
          : null,
      experienceYears: json['experience_years'] as int? ?? 0,
      emergencyContact: json['emergency_contact'] as String?,
      emergencyContactName: json['emergency_contact_name'] as String?,
      employmentStatus: json['employment_status'] as String? ?? 'pending',
      profileCompleted: json['profile_completed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      hireDate: json['hire_date'] != null
          ? DateTime.parse(json['hire_date'] as String)
          : null,
      totalTripsCompleted: json['total_trips_completed'] as int?,
      performanceRating: (json['performance_rating'] as num?)?.toDouble(),
    );
  }

  /// Convert StaffModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'bus_owner_id': busOwnerId,
      'staff_type': staffType,
      'license_number': licenseNumber,
      'license_expiry_date': licenseExpiryDate?.toIso8601String(),
      'experience_years': experienceYears,
      'emergency_contact': emergencyContact,
      'emergency_contact_name': emergencyContactName,
      'employment_status': employmentStatus,
      'profile_completed': profileCompleted,
      'created_at': createdAt?.toIso8601String(),
      'hire_date': hireDate?.toIso8601String(),
      'total_trips_completed': totalTripsCompleted,
      'performance_rating': performanceRating,
    };
  }

  /// Convert to domain entity
  Staff toEntity() {
    return Staff(
      id: id,
      userId: userId,
      busOwnerId: busOwnerId,
      staffType: staffType,
      licenseNumber: licenseNumber,
      licenseExpiryDate: licenseExpiryDate,
      experienceYears: experienceYears,
      emergencyContact: emergencyContact,
      emergencyContactName: emergencyContactName,
      employmentStatus: employmentStatus,
      profileCompleted: profileCompleted,
      createdAt: createdAt,
      hireDate: hireDate,
      totalTripsCompleted: totalTripsCompleted,
      performanceRating: performanceRating,
    );
  }

  /// Create from domain entity
  factory StaffModel.fromEntity(Staff staff) {
    return StaffModel(
      id: staff.id,
      userId: staff.userId,
      busOwnerId: staff.busOwnerId,
      staffType: staff.staffType,
      licenseNumber: staff.licenseNumber,
      licenseExpiryDate: staff.licenseExpiryDate,
      experienceYears: staff.experienceYears,
      emergencyContact: staff.emergencyContact,
      emergencyContactName: staff.emergencyContactName,
      employmentStatus: staff.employmentStatus,
      profileCompleted: staff.profileCompleted,
      createdAt: staff.createdAt,
      hireDate: staff.hireDate,
      totalTripsCompleted: staff.totalTripsCompleted,
      performanceRating: staff.performanceRating,
    );
  }
}
