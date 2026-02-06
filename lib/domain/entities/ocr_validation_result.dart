import 'package:equatable/equatable.dart';

/// Entity representing the result of OCR validation for NIC
class OCRValidationResult extends Equatable {
  final bool isValid;
  final String? extractedNIC;
  final String? expectedNIC;
  final double confidence;
  final String? errorMessage;
  final List<String> allExtractedTexts;

  const OCRValidationResult({
    required this.isValid,
    this.extractedNIC,
    this.expectedNIC,
    required this.confidence,
    this.errorMessage,
    required this.allExtractedTexts,
  });

  @override
  List<Object?> get props => [
        isValid,
        extractedNIC,
        expectedNIC,
        confidence,
        errorMessage,
        allExtractedTexts,
      ];

  /// Factory for successful validation
  factory OCRValidationResult.success({
    required String extractedNIC,
    required String expectedNIC,
    required double confidence,
    required List<String> allExtractedTexts,
  }) {
    return OCRValidationResult(
      isValid: true,
      extractedNIC: extractedNIC,
      expectedNIC: expectedNIC,
      confidence: confidence,
      allExtractedTexts: allExtractedTexts,
    );
  }

  /// Factory for failed validation
  factory OCRValidationResult.failure({
    String? extractedNIC,
    String? expectedNIC,
    required String errorMessage,
    double confidence = 0.0,
    required List<String> allExtractedTexts,
  }) {
    return OCRValidationResult(
      isValid: false,
      extractedNIC: extractedNIC,
      expectedNIC: expectedNIC,
      confidence: confidence,
      errorMessage: errorMessage,
      allExtractedTexts: allExtractedTexts,
    );
  }

  /// Factory for no text found
  factory OCRValidationResult.noTextFound() {
    return const OCRValidationResult(
      isValid: false,
      errorMessage: 'No text detected in the image. Please ensure the NIC is clear and well-lit.',
      confidence: 0.0,
      allExtractedTexts: [],
    );
  }

  /// Factory for NIC format error
  factory OCRValidationResult.invalidFormat({
    required List<String> allExtractedTexts,
  }) {
    return OCRValidationResult(
      isValid: false,
      errorMessage: 'Could not find a valid NIC number in the image. Please ensure the NIC is clearly visible.',
      confidence: 0.0,
      allExtractedTexts: allExtractedTexts,
    );
  }

  /// Factory for mismatch error
  factory OCRValidationResult.mismatch({
    required String extractedNIC,
    required String expectedNIC,
    required double confidence,
    required List<String> allExtractedTexts,
  }) {
    return OCRValidationResult(
      isValid: false,
      extractedNIC: extractedNIC,
      expectedNIC: expectedNIC,
      errorMessage: 'The NIC number on the image ($extractedNIC) does not match the entered NIC ($expectedNIC).',
      confidence: confidence,
      allExtractedTexts: allExtractedTexts,
    );
  }

  /// Get user-friendly message
  String get message {
    if (isValid) {
      return 'NIC verified successfully! Match confidence: ${(confidence * 100).toStringAsFixed(1)}%';
    }
    return errorMessage ?? 'Validation failed';
  }

  /// Check if confidence is high enough (>70%)
  bool get hasHighConfidence => confidence >= 0.7;

  /// Check if confidence is medium (50-70%)
  bool get hasMediumConfidence => confidence >= 0.5 && confidence < 0.7;

  /// Check if confidence is low (<50%)
  bool get hasLowConfidence => confidence < 0.5;

  /// Get extracted text (alias for extractedNIC for compatibility)
  String get extractedText => extractedNIC ?? '';

  /// Get match result (alias for isValid for compatibility)
  bool get isMatch => isValid;
}
