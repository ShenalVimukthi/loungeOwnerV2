import 'package:equatable/equatable.dart';

/// Entity representing the registration progress of a lounge owner
class RegistrationProgress extends Equatable {
  final String currentStep;
  final bool phoneVerified;
  final bool personalInfoCompleted;
  final bool nicImagesUploaded;
  final bool loungeAdded;
  final bool registrationCompleted;
  final int ocrAttemptsRemaining;
  final bool isOcrBlocked;
  final DateTime? ocrBlockedUntil;
  final String? verificationStatus; // null if no lounge added yet

  const RegistrationProgress({
    required this.currentStep,
    required this.phoneVerified,
    required this.personalInfoCompleted,
    required this.nicImagesUploaded,
    required this.loungeAdded,
    required this.registrationCompleted,
    required this.ocrAttemptsRemaining,
    required this.isOcrBlocked,
    this.ocrBlockedUntil,
    this.verificationStatus,
  });

  @override
  List<Object?> get props => [
        currentStep,
        phoneVerified,
        personalInfoCompleted,
        nicImagesUploaded,
        loungeAdded,
        registrationCompleted,
        ocrAttemptsRemaining,
        isOcrBlocked,
        ocrBlockedUntil,
        verificationStatus,
      ];

  /// Get the step index for progress indicator (0-4)
  int get stepIndex {
    switch (currentStep) {
      case 'phone_verified':
        return 0;
      case 'personal_info':
        return 1;
      case 'nic_uploaded':
        return 2;
      case 'lounge_added':
        return 3;
      case 'completed':
        return 4;
      default:
        return 0;
    }
  }

  /// Get human-readable step name
  String get stepName {
    switch (currentStep) {
      case 'phone_verified':
        return 'Phone Verification';
      case 'personal_info':
        return 'Personal Information';
      case 'nic_uploaded':
        return 'NIC Verification';
      case 'lounge_added':
        return 'Lounge Details';
      case 'completed':
        return 'Waiting for Approval';
      default:
        return 'Unknown';
    }
  }

  /// Get next step name
  String? get nextStepName {
    switch (currentStep) {
      case 'phone_verified':
        return 'Personal Information';
      case 'personal_info':
        return 'NIC Verification';
      case 'nic_uploaded':
        return 'Lounge Details';
      case 'lounge_added':
        return 'Waiting for Approval';
      case 'completed':
        return null; // No next step
      default:
        return 'Unknown';
    }
  }

  /// Check if can proceed to next step
  bool get canProceed {
    if (isOcrBlocked) return false;
    if (currentStep == 'completed') return false;
    return true;
  }

  /// Check if OCR step is accessible
  bool get canAccessOCRStep {
    return personalInfoCompleted && !isOcrBlocked && ocrAttemptsRemaining > 0;
  }

  /// Get message for OCR block
  String? get ocrBlockMessage {
    if (!isOcrBlocked || ocrBlockedUntil == null) return null;

    final now = DateTime.now();
    final difference = ocrBlockedUntil!.difference(now);

    if (difference.inHours > 0) {
      return 'Too many failed attempts. Please try again after ${difference.inHours} hours.';
    } else if (difference.inMinutes > 0) {
      return 'Too many failed attempts. Please try again after ${difference.inMinutes} minutes.';
    } else {
      return 'Your OCR block has expired. You can try again.';
    }
  }

  /// Get OCR attempts message
  String get ocrAttemptsMessage {
    if (ocrAttemptsRemaining == 4) {
      return 'You have 4 attempts to verify your NIC.';
    } else if (ocrAttemptsRemaining > 0) {
      return 'You have $ocrAttemptsRemaining ${ocrAttemptsRemaining == 1 ? 'attempt' : 'attempts'} remaining.';
    } else {
      return 'You have exhausted all attempts. Please contact support.';
    }
  }

  /// Get overall completion percentage
  double get completionPercentage {
    int completedSteps = 0;
    if (phoneVerified) completedSteps++;
    if (personalInfoCompleted) completedSteps++;
    if (nicImagesUploaded) completedSteps++;
    if (loungeAdded) completedSteps++;
    if (registrationCompleted) completedSteps++;

    return (completedSteps / 5) * 100;
  }

  RegistrationProgress copyWith({
    String? currentStep,
    bool? phoneVerified,
    bool? personalInfoCompleted,
    bool? nicImagesUploaded,
    bool? loungeAdded,
    bool? registrationCompleted,
    int? ocrAttemptsRemaining,
    bool? isOcrBlocked,
    DateTime? ocrBlockedUntil,
    String? verificationStatus,
  }) {
    return RegistrationProgress(
      currentStep: currentStep ?? this.currentStep,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      personalInfoCompleted: personalInfoCompleted ?? this.personalInfoCompleted,
      nicImagesUploaded: nicImagesUploaded ?? this.nicImagesUploaded,
      loungeAdded: loungeAdded ?? this.loungeAdded,
      registrationCompleted: registrationCompleted ?? this.registrationCompleted,
      ocrAttemptsRemaining: ocrAttemptsRemaining ?? this.ocrAttemptsRemaining,
      isOcrBlocked: isOcrBlocked ?? this.isOcrBlocked,
      ocrBlockedUntil: ocrBlockedUntil ?? this.ocrBlockedUntil,
      verificationStatus: verificationStatus ?? this.verificationStatus,
    );
  }
}
