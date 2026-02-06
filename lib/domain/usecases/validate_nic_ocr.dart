import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/ocr_validation_result.dart';

class ValidateNICOCR {
  final TextRecognizer textRecognizer;

  ValidateNICOCR(this.textRecognizer);

  Future<Either<Failure, OCRValidationResult>> call({
    required String imagePath,
    required String userInputNIC,
  }) async {
    try {
      final inputImage = InputImage.fromFilePath(imagePath);
      final recognizedText = await textRecognizer.processImage(inputImage);

      // Extract all text blocks
      final allTexts = recognizedText.blocks
          .expand((block) => block.lines)
          .map((line) => line.text)
          .toList();

      if (recognizedText.text.isEmpty) {
        return Right(OCRValidationResult.noTextFound());
      }

      // Extract NIC number from recognized text
      final nicPattern = RegExp(r'\b(\d{9}[VvXx]|\d{12})\b');
      final matches = nicPattern.allMatches(recognizedText.text);

      if (matches.isEmpty) {
        return Right(OCRValidationResult.invalidFormat(
          allExtractedTexts: allTexts,
        ));
      }

      // Get the first match (most likely the NIC)
      final extractedNIC = matches.first.group(0)?.toUpperCase() ?? '';
      final normalizedUserInput = userInputNIC.trim().toUpperCase();

      // Calculate confidence based on text quality
      double confidence = 0.0;
      if (recognizedText.blocks.isNotEmpty) {
        final confidences = recognizedText.blocks
            .expand((block) => block.lines)
            .map((line) => line.confidence ?? 0.0);
        
        if (confidences.isNotEmpty) {
          confidence = confidences.reduce((a, b) => a + b) / confidences.length;
        }
      }

      final isValid = extractedNIC == normalizedUserInput;

      if (isValid) {
        return Right(OCRValidationResult.success(
          extractedNIC: extractedNIC,
          expectedNIC: normalizedUserInput,
          confidence: confidence,
          allExtractedTexts: allTexts,
        ));
      } else {
        return Right(OCRValidationResult.mismatch(
          extractedNIC: extractedNIC,
          expectedNIC: normalizedUserInput,
          confidence: confidence,
          allExtractedTexts: allTexts,
        ));
      }
    } catch (e) {
      return Left(OCRFailure('OCR processing failed: ${e.toString()}'));
    }
  }

  void dispose() {
    textRecognizer.close();
  }
}
