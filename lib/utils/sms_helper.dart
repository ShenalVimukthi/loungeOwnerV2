import 'package:sms_autofill/sms_autofill.dart';
import 'package:logger/logger.dart';

/// Helper class for SMS OTP auto-read functionality
class SmsHelper {
  static final _logger = Logger();

  /// Get the app signature hash
  /// This hash must be included in the SMS message for auto-read to work
  ///
  /// Format: The SMS should end with angle brackets and hash
  /// Example: Your SmartTransit OTP is: 123456 followed by hash
  static Future<String?> getAppSignature() async {
    try {
      final signature = await SmsAutoFill().getAppSignature;
      return signature;
    } catch (e) {
      _logger.e('Error getting app signature: $e');
      return null;
    }
  }

  /// Print app signature for debugging
  /// Call this during development to get the hash for your backend
  static Future<void> printAppSignature() async {
    final signature = await getAppSignature();
    if (signature != null) {
      _logger.i('═══════════════════════════════════════');
      _logger.i('📱 APP SIGNATURE HASH: $signature');
      _logger.i('═══════════════════════════════════════');
      _logger.i('Add this hash to your backend SMS messages:');
      _logger.i('');
      _logger.i('Example SMS format:');
      _logger.i('Your SmartTransit OTP is: 123456');
      _logger.i(signature);
      _logger.i('═══════════════════════════════════════');
    } else {
      _logger.w('⚠️  Failed to get app signature');
    }
  }
}
