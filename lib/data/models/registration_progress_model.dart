import '../../domain/entities/registration_progress.dart';

/// Model for RegistrationProgress that handles backend JSON format
/// Backend uses different field names and structure than domain entity
class RegistrationProgressModel extends RegistrationProgress {
  const RegistrationProgressModel({
    required super.currentStep,
    required super.phoneVerified,
    required bool businessInfoCompleted,
    required super.nicImagesUploaded,
    required super.loungeAdded,
    required super.registrationCompleted,
    required super.ocrAttemptsRemaining,
    required super.isOcrBlocked,
    super.ocrBlockedUntil,
    super.verificationStatus,
    int? totalStaff,
  }) : super(personalInfoCompleted: businessInfoCompleted);

  factory RegistrationProgressModel.fromJson(Map<String, dynamic> json) {
    // Parse steps object
    final stepsMap = json['steps'] as Map<String, dynamic>? ?? {};

    return RegistrationProgressModel(
      currentStep: json['registration_step'] as String? ?? 'phone_verified',
      phoneVerified: stepsMap['phone_verified'] as bool? ?? false,
      businessInfoCompleted: stepsMap['business_info'] as bool? ?? false,
      nicImagesUploaded: stepsMap['nic_uploaded'] as bool? ?? false,
      loungeAdded: stepsMap['lounge_added'] as bool? ?? false,
      registrationCompleted: stepsMap['completed'] as bool? ?? false,
      ocrAttemptsRemaining: 4 - (json['ocr_attempts'] as int? ?? 0),
      isOcrBlocked: json['ocr_blocked'] as bool? ?? false,
      ocrBlockedUntil: json['ocr_blocked_until'] != null
          ? DateTime.parse(json['ocr_blocked_until'] as String)
          : null,
      verificationStatus: json['verification_status'] as String?,
      totalStaff: json['total_staff'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'registration_step': currentStep,
      'profile_completed': registrationCompleted,
      'verification_status': verificationStatus,
      'ocr_attempts': 4 - ocrAttemptsRemaining,
      'ocr_blocked': isOcrBlocked,
      'ocr_blocked_until': ocrBlockedUntil?.toIso8601String(),
      'retry_after_seconds': null,
      'total_lounges': loungeAdded ? 1 : 0,
      'steps': {
        'phone_verified': phoneVerified,
        'business_info': personalInfoCompleted,
        'nic_uploaded': nicImagesUploaded,
        'lounge_added': loungeAdded,
        'completed': registrationCompleted,
      },
    };
  }
}
