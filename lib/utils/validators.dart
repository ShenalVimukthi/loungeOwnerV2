import '../config/constants.dart';

class Validators {
  // Phone Number Validator
  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove any non-digit characters
    final cleanNumber = value.replaceAll(RegExp(r'\D'), '');

    // Check if it starts with 0 and has 10 digits, or has 9 digits
    if (cleanNumber.length == AppConstants.phoneNumberLengthWithZero) {
      if (!cleanNumber.startsWith('0')) {
        return 'Phone number should start with 0';
      }
      return null;
    } else if (cleanNumber.length == AppConstants.phoneNumberLength) {
      return null;
    }

    return 'Please enter a valid Sri Lankan phone number';
  }

  // Email Validator
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Email is optional
    }

    if (!AppConstants.emailPattern.hasMatch(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  // OTP Validator
  static String? validateOtp(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (value.length != AppConstants.otpLength) {
      return 'OTP must be ${AppConstants.otpLength} digits';
    }

    if (!AppConstants.otpPattern.hasMatch(value)) {
      return 'OTP must contain only numbers';
    }

    return null;
  }

  // Name Validator
  static String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Name is optional
    }

    if (value.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }

    if (value.trim().length > 50) {
      return 'Name must be less than 50 characters';
    }

    return null;
  }

  // Required Field Validator
  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  // Generic Length Validator
  static String? validateLength(
    String? value,
    int minLength,
    int maxLength,
    String fieldName,
  ) {
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    if (value.length > maxLength) {
      return '$fieldName must be less than $maxLength characters';
    }

    return null;
  }

  // NIC validation - Sri Lankan format
  static String? validateNIC(String? value) {
    if (value == null || value.isEmpty) {
      return 'NIC number is required';
    }

    final nicValue = value.trim().toUpperCase();

    // Old format: 9 digits + V/X (e.g., 123456789V)
    final oldNicRegex = RegExp(r'^\d{9}[VX]$');
    // New format: 12 digits (e.g., 199912345678)
    final newNicRegex = RegExp(r'^\d{12}$');

    if (!oldNicRegex.hasMatch(nicValue) && !newNicRegex.hasMatch(nicValue)) {
      return 'Invalid NIC format (9 digits + V/X or 12 digits)';
    }

    return null;
  }

  // Number validation
  static String? validateNumber(
    String? value, {
    String? fieldName,
    int? min,
    int? max,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'This field'} is required';
    }

    final number = int.tryParse(value.trim());

    if (number == null) {
      return 'Please enter a valid number';
    }

    if (min != null && number < min) {
      return '${fieldName ?? 'Value'} must be at least $min';
    }

    if (max != null && number > max) {
      return '${fieldName ?? 'Value'} must not exceed $max';
    }

    return null;
  }

  // Decimal number validation (for prices)
  static String? validatePrice(String? value, {String? fieldName}) {
    if (value == null || value.trim().isEmpty) {
      return '${fieldName ?? 'Price'} is required';
    }

    final price = double.tryParse(value.trim());

    if (price == null) {
      return 'Please enter a valid price';
    }

    if (price < 0) {
      return 'Price cannot be negative';
    }

    if (price > 999999) {
      return 'Price is too high';
    }

    return null;
  }

  // Address validation
  static String? validateAddress(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Address is required';
    }

    if (value.trim().length < 10) {
      return 'Please enter a complete address (at least 10 characters)';
    }

    return null;
  }

  // Postal code validation
  static String? validatePostalCode(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Postal code is optional
    }

    if (!RegExp(r'^\d{5}$').hasMatch(value.trim())) {
      return 'Postal code must be 5 digits';
    }

    return null;
  }

  // Capacity validation
  static String? validateCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Capacity is required';
    }

    final capacity = int.tryParse(value.trim());

    if (capacity == null) {
      return 'Please enter a valid number';
    }

    if (capacity <= 0) {
      return 'Capacity must be greater than 0';
    }

    if (capacity > 1000) {
      return 'Capacity seems too high';
    }

    return null;
  }

  // Password validation
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  // OTP validation
  static String? validateOTP(String? value) {
    if (value == null || value.isEmpty) {
      return 'OTP is required';
    }

    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
      return 'OTP must be 6 digits';
    }

    return null;
  }

  // Business license validation
  static String? validateBusinessLicense(String? value) {
    // Optional field
    if (value == null || value.isEmpty) {
      return null;
    }

    if (value.trim().length < 5) {
      return 'Business license must be at least 5 characters';
    }

    return null;
  }
}
