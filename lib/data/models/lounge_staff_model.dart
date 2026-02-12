import '../../domain/entities/lounge_staff.dart';

/// Data Model: Lounge Staff
/// Handles JSON serialization/deserialization for API communication
class LoungeStaffModel extends LoungeStaff {
  const LoungeStaffModel({
    required super.id,
    required super.userId,
    required super.loungeId,
    required super.fullName,
    required super.nicNumber,
    super.email,
    super.phone,
    required super.profileCompleted,
    required super.approvalStatus,
    required super.employmentStatus,
    super.hiredDate,
    super.terminatedDate,
    super.notes,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON (from API response)
  factory LoungeStaffModel.fromJson(Map<String, dynamic> json) {
    final fullName = (json['full_name'] ?? json['first_name'] ?? '') as String;
    final userId = (json['user_id'] ?? json['userId'] ?? '') as String;
    final loungeId = (json['lounge_id'] ?? json['loungeId'] ?? '') as String;
    final nicNumber = (json['nic_number'] ?? json['nicNumber'] ?? '') as String;

    return LoungeStaffModel(
      id: json['id'] as String,
      userId: userId,
      loungeId: loungeId,
      fullName: fullName,
      nicNumber: nicNumber,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      profileCompleted: json['profile_completed'] as bool? ?? false,
      approvalStatus: json['approval_status'] as String? ?? 'pending',
      employmentStatus: json['employment_status'] as String? ?? 'active',
      hiredDate: json['hired_date'] != null
          ? DateTime.parse(json['hired_date'] as String)
          : null,
      terminatedDate: json['terminated_date'] != null
          ? DateTime.parse(json['terminated_date'] as String)
          : null,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert model to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'lounge_id': loungeId,
      'full_name': fullName,
      'nic_number': nicNumber,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      'profile_completed': profileCompleted,
      'approval_status': approvalStatus,
      'employment_status': employmentStatus,
      if (hiredDate != null) 'hired_date': hiredDate!.toIso8601String(),
      if (terminatedDate != null)
        'terminated_date': terminatedDate!.toIso8601String(),
      if (notes != null) 'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert from domain entity
  factory LoungeStaffModel.fromEntity(LoungeStaff entity) {
    return LoungeStaffModel(
      id: entity.id,
      userId: entity.userId,
      loungeId: entity.loungeId,
      fullName: entity.fullName,
      nicNumber: entity.nicNumber,
      email: entity.email,
      phone: entity.phone,
      profileCompleted: entity.profileCompleted,
      approvalStatus: entity.approvalStatus,
      employmentStatus: entity.employmentStatus,
      hiredDate: entity.hiredDate,
      terminatedDate: entity.terminatedDate,
      notes: entity.notes,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
