import '../../domain/entities/auth_tokens.dart';

/// Data Model: Authentication Tokens
/// Handles storage and retrieval of JWT tokens
class AuthTokensModel extends AuthTokens {
  AuthTokensModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresIn,
    required super.expiryTime,
  });

  /// Create from API response
  factory AuthTokensModel.fromJson(Map<String, dynamic> json) {
    final expiresIn = json['expires_in_seconds'] as int? ??
                      json['expires_in'] as int? ??
                      3600; // Default 1 hour

    return AuthTokensModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: expiresIn,
      expiryTime: DateTime.now().add(Duration(seconds: expiresIn)),
    );
  }

  /// Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_in': expiresIn,
      'expiry_time': expiryTime.toIso8601String(),
    };
  }

  /// Create from storage JSON
  factory AuthTokensModel.fromStorage(Map<String, dynamic> json) {
    return AuthTokensModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiresIn: json['expires_in'] as int,
      expiryTime: DateTime.parse(json['expiry_time'] as String),
    );
  }

  /// Convert to domain entity
  AuthTokens toEntity() {
    return AuthTokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresIn: expiresIn,
      expiryTime: expiryTime,
    );
  }
}
