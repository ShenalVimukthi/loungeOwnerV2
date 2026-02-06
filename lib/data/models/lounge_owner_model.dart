import '../../domain/entities/lounge_owner.dart';

/// Model for LoungeOwner that extends the entity and handles backend JSON
/// Backend has business and manager fields for the new multi-entity structure
/// Note: total_lounges and total_staff are dynamically calculated by backend
class LoungeOwnerModel extends LoungeOwner {
  final int? totalLounges; // Dynamic count from backend
  final int? totalStaff; // Dynamic count from backend

  const LoungeOwnerModel({
    required super.id,
    required super.userId,
    super.businessName,
    super.businessLicense,
    super.managerFullName,
    super.managerNicNumber,
    super.managerEmail,
    required super.registrationStep,
    required super.profileCompleted,
    required super.verificationStatus,
    super.verificationNotes,
    super.verifiedAt,
    super.nicOcrAttempts,
    super.lastOcrAttemptAt,
    super.ocrBlockedUntil,
    required super.createdAt,
    required super.updatedAt,
    this.totalLounges,
    this.totalStaff,
  });

  factory LoungeOwnerModel.fromJson(Map<String, dynamic> json) {
    // 🔍 DEBUG: Log raw JSON values
    print('🔍 LoungeOwnerModel.fromJson - Raw JSON:');
    print('   registration_step: ${json['registration_step']}');
    print('   profile_completed: ${json['profile_completed']}');

    final model = LoungeOwnerModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String?,
      businessLicense: json['business_license'] as String?,
      managerFullName: json['manager_full_name'] as String?,
      managerNicNumber: json['manager_nic_number'] as String?,
      managerEmail: json['manager_email'] as String?,
      registrationStep:
          json['registration_step'] as String? ?? 'phone_verified',
      profileCompleted: json['profile_completed'] as bool? ?? false,
      verificationStatus: json['verification_status'] as String? ?? 'pending',
      verificationNotes: json['verification_notes'] as String?,
      verifiedAt: json['verified_at'] != null
          ? DateTime.parse(json['verified_at'] as String)
          : null,
      nicOcrAttempts: json['nic_ocr_attempts'] as int? ?? 0,
      lastOcrAttemptAt: json['last_ocr_attempt_at'] != null
          ? DateTime.parse(json['last_ocr_attempt_at'] as String)
          : null,
      ocrBlockedUntil: json['ocr_blocked_until'] != null
          ? DateTime.parse(json['ocr_blocked_until'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      totalLounges: json['total_lounges'] as int? ?? 0,
      totalStaff: json['total_staff'] as int? ?? 0,
    );

    // 🔍 DEBUG: Log parsed model values
    print('🔍 LoungeOwnerModel.fromJson - Parsed model:');
    print('   registrationStep: ${model.registrationStep}');
    print('   profileCompleted: ${model.profileCompleted}');

    return model;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'business_name': businessName,
      'business_license': businessLicense,
      'manager_full_name': managerFullName,
      'manager_nic_number': managerNicNumber,
      'manager_email': managerEmail,
      'registration_step': registrationStep,
      'profile_completed': profileCompleted,
      'verification_status': verificationStatus,
      'verification_notes': verificationNotes,
      'verified_at': verifiedAt?.toIso8601String(),
      'nic_ocr_attempts': nicOcrAttempts,
      'last_ocr_attempt_at': lastOcrAttemptAt?.toIso8601String(),
      'ocr_blocked_until': ocrBlockedUntil?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'total_lounges': totalLounges,
      'total_staff': totalStaff,
    };
  }

  @override
  LoungeOwnerModel copyWith({
    String? id,
    String? userId,
    String? businessName,
    String? businessLicense,
    String? managerFullName,
    String? managerNicNumber,
    String? managerEmail,
    String? registrationStep,
    bool? profileCompleted,
    String? verificationStatus,
    String? verificationNotes,
    DateTime? verifiedAt,
    int? nicOcrAttempts,
    DateTime? lastOcrAttemptAt,
    DateTime? ocrBlockedUntil,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalLounges,
    int? totalStaff,
  }) {
    return LoungeOwnerModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      businessLicense: businessLicense ?? this.businessLicense,
      managerFullName: managerFullName ?? this.managerFullName,
      managerNicNumber: managerNicNumber ?? this.managerNicNumber,
      managerEmail: managerEmail ?? this.managerEmail,
      registrationStep: registrationStep ?? this.registrationStep,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verificationNotes: verificationNotes ?? this.verificationNotes,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      nicOcrAttempts: nicOcrAttempts ?? this.nicOcrAttempts,
      lastOcrAttemptAt: lastOcrAttemptAt ?? this.lastOcrAttemptAt,
      ocrBlockedUntil: ocrBlockedUntil ?? this.ocrBlockedUntil,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalLounges: totalLounges ?? this.totalLounges,
      totalStaff: totalStaff ?? this.totalStaff,
    );
  }
}
