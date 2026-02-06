import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../models/auth_tokens_model.dart';
import '../../core/error/exceptions.dart';

/// Local Data Source: Authentication Storage
/// Handles secure local storage of auth data
abstract class AuthLocalDataSource {
  Future<void> saveTokens(AuthTokensModel tokens);
  Future<AuthTokensModel?> getTokens();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearAll();
  Future<bool> hasValidTokens();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;

  // Storage keys
  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _tokenExpiryKey = 'token_expiry';
  static const String _userDataKey = 'user_data';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveTokens(AuthTokensModel tokens) async {
    try {
      await Future.wait([
        secureStorage.write(key: _accessTokenKey, value: tokens.accessToken),
        secureStorage.write(key: _refreshTokenKey, value: tokens.refreshToken),
        secureStorage.write(
          key: _tokenExpiryKey,
          value: tokens.expiryTime.toIso8601String(),
        ),
      ]);
    } catch (e) {
      throw CacheException('Failed to save tokens: $e');
    }
  }

  @override
  Future<AuthTokensModel?> getTokens() async {
    try {
      final results = await Future.wait([
        secureStorage.read(key: _accessTokenKey),
        secureStorage.read(key: _refreshTokenKey),
        secureStorage.read(key: _tokenExpiryKey),
      ]);

      final accessToken = results[0];
      final refreshToken = results[1];
      final expiryString = results[2];

      if (accessToken == null || refreshToken == null || expiryString == null) {
        return null;
      }

      final expiryTime = DateTime.parse(expiryString);
      final expiresIn = expiryTime.difference(DateTime.now()).inSeconds;

      return AuthTokensModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
        expiresIn: expiresIn > 0 ? expiresIn : 0,
        expiryTime: expiryTime,
      );
    } catch (e) {
      throw CacheException('Failed to get tokens: $e');
    }
  }

  @override
  Future<void> saveUser(UserModel user) async {
    try {
      final userJson = jsonEncode(user.toJson());
      await secureStorage.write(key: _userDataKey, value: userJson);
    } catch (e) {
      throw CacheException('Failed to save user: $e');
    }
  }

  @override
  Future<UserModel?> getUser() async {
    try {
      final userJson = await secureStorage.read(key: _userDataKey);
      if (userJson == null) return null;

      final userData = jsonDecode(userJson) as Map<String, dynamic>;
      return UserModel.fromJson(userData);
    } catch (e) {
      throw CacheException('Failed to get user: $e');
    }
  }

  @override
  Future<void> clearAll() async {
    try {
      await Future.wait([
        secureStorage.delete(key: _accessTokenKey),
        secureStorage.delete(key: _refreshTokenKey),
        secureStorage.delete(key: _tokenExpiryKey),
        secureStorage.delete(key: _userDataKey),
      ]);
    } catch (e) {
      throw CacheException('Failed to clear storage: $e');
    }
  }

  @override
  Future<bool> hasValidTokens() async {
    try {
      final tokens = await getTokens();
      if (tokens == null) return false;

      // Check if token is expired
      return !tokens.isExpired;
    } catch (e) {
      return false;
    }
  }
}
