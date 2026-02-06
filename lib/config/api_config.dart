class ApiConfig {
  // ============================================
  // DUAL BACKEND CONFIGURATION
  // ============================================
  // - Choreo Backend: Auth, OTP, User Profile (SMS configured, production-ready)
  // - Local Backend: Lounge APIs (staff, bookings, etc. - for development)

  // CHOREO BACKEND - For Auth, OTP, and general APIs
  static const String choreoBaseUrl =
      'https://a9a9815d-fed9-4f0e-bf6f-706f789df0f3-dev.e1-us-east-azure.choreoapis.dev/default/backend/v1.0';

  // LOCAL BACKEND - For Lounge-specific APIs (staff, bookings)
  // Android Emulator:
  // static const String localBaseUrl = 'http://10.0.2.2:8080';

  // iOS Simulator (uncomment below and comment above):
  // static const String localBaseUrl = 'http://localhost:8080';

  // Physical Device - Using your computer's Wi-Fi IP:
  static const String localBaseUrl = 'http://192.168.43.180:8080';

  // Default base URL for backward compatibility
  static const String baseUrl = choreoBaseUrl;

  // API Endpoints
  static const String sendOtpEndpoint = '/api/v1/auth/send-otp';
  static const String verifyOtpEndpoint =
      '/api/v1/auth/verify-otp'; // For passenger app only
  static const String verifyOtpStaffEndpoint =
      '/api/v1/auth/verify-otp-staff'; // For staff app - NEW
  static const String refreshTokenEndpoint = '/api/v1/auth/refresh';
  static const String profileEndpoint = '/api/v1/user/profile';
  static const String updateProfileEndpoint = '/api/v1/user/profile';
  static const String logoutEndpoint = '/api/v1/auth/logout';
  static const String staffEndpoint = '/api/v1/staff';

  // Helper methods to get the correct base URL
  static String getAuthBaseUrl() => choreoBaseUrl;
  static String getLoungeBaseUrl() => localBaseUrl;

  // Full URLs - Auth APIs use Choreo
  static String get sendOtpUrl => '${getAuthBaseUrl()}$sendOtpEndpoint';
  static String get verifyOtpUrl => '${getAuthBaseUrl()}$verifyOtpEndpoint';
  static String get verifyOtpStaffUrl =>
      '${getAuthBaseUrl()}$verifyOtpStaffEndpoint';
  static String get refreshTokenUrl =>
      '${getAuthBaseUrl()}$refreshTokenEndpoint';
  static String get profileUrl => '${getAuthBaseUrl()}$profileEndpoint';
  static String get updateProfileUrl =>
      '${getAuthBaseUrl()}$updateProfileEndpoint';
  static String get logoutUrl => '${getAuthBaseUrl()}$logoutEndpoint';
  static String get staffUrl => '${getAuthBaseUrl()}$staffEndpoint';

  // Lounge-specific APIs use local backend
  static String loungeUrl(String loungeId, String path) =>
      '${getLoungeBaseUrl()}/api/v1/lounges/$loungeId$path';
  static String loungeStaffUrl(String loungeId) =>
      '${getLoungeBaseUrl()}/api/v1/lounges/$loungeId/staff';
  static String loungeBookingsUrl(String loungeId) =>
      '${getLoungeBaseUrl()}/api/v1/lounges/$loungeId/bookings';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
}
