/// Domain Entity: Authentication Tokens
class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final int expiresIn; // seconds
  final DateTime expiryTime;

  AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.expiryTime,
  });

  /// Business logic: Check if token is expired
  bool get isExpired => DateTime.now().isAfter(expiryTime);

  /// Business logic: Check if token needs refresh (5 minutes before expiry)
  bool get needsRefresh {
    final fiveMinutesBeforeExpiry = expiryTime.subtract(const Duration(minutes: 5));
    return DateTime.now().isAfter(fiveMinutesBeforeExpiry);
  }

  /// Business logic: Get remaining time in seconds
  int get remainingSeconds {
    final remaining = expiryTime.difference(DateTime.now()).inSeconds;
    return remaining > 0 ? remaining : 0;
  }

  @override
  String toString() => 'AuthTokens(expires in: ${remainingSeconds}s)';
}
