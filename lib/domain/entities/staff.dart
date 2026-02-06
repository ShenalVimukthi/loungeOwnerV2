/// Domain Entity: Staff
/// Represents driver or conductor business model
class Staff {
  final String id;
  final String userId;
  final String? busOwnerId;
  final String staffType; // 'driver' or 'conductor'
  final String? licenseNumber;
  final DateTime? licenseExpiryDate;
  final int experienceYears;
  final String? emergencyContact;
  final String? emergencyContactName;
  final String employmentStatus;
  final bool profileCompleted;
  final DateTime? createdAt;
  final DateTime? hireDate;
  final int? totalTripsCompleted;
  final double? performanceRating;

  Staff({
    required this.id,
    required this.userId,
    this.busOwnerId,
    required this.staffType,
    this.licenseNumber,
    this.licenseExpiryDate,
    required this.experienceYears,
    this.emergencyContact,
    this.emergencyContactName,
    required this.employmentStatus,
    required this.profileCompleted,
    this.createdAt,
    this.hireDate,
    this.totalTripsCompleted,
    this.performanceRating,
  });

  /// Business logic: Check if driver
  bool get isDriver => staffType.toLowerCase() == 'driver';

  /// Business logic: Check if conductor
  bool get isConductor => staffType.toLowerCase() == 'conductor';

  /// Business logic: Check employment status
  bool get isPending => employmentStatus.toLowerCase() == 'pending';
  bool get isActive => employmentStatus.toLowerCase() == 'active';
  bool get isInactive => employmentStatus.toLowerCase() == 'inactive';
  bool get isSuspended => employmentStatus.toLowerCase() == 'suspended';

  /// Business logic: Get display role
  String get roleDisplay {
    return staffType.substring(0, 1).toUpperCase() +
           staffType.substring(1).toLowerCase();
  }

  /// Business logic: Get display status
  String get displayStatus {
    return employmentStatus.substring(0, 1).toUpperCase() +
           employmentStatus.substring(1).toLowerCase();
  }

  /// Business logic: Check if license is expiring soon (within 30 days)
  bool get isLicenseExpiringSoon {
    if (licenseExpiryDate == null) return false;
    final daysUntilExpiry = licenseExpiryDate!.difference(DateTime.now()).inDays;
    return daysUntilExpiry <= 30 && daysUntilExpiry >= 0;
  }

  /// Business logic: Check if license is expired
  bool get isLicenseExpired {
    if (licenseExpiryDate == null) return false;
    return licenseExpiryDate!.isBefore(DateTime.now());
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Staff && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'Staff(id: $id, type: $staffType, status: $employmentStatus)';
}
