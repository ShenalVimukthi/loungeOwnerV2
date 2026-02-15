import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/models/auth_tokens_model.dart';

class ApiClient {
  late final Dio _dio;
  final AuthLocalDataSource _authLocalDataSource;
  bool _isRefreshing = false; // Lock to prevent concurrent refresh attempts
  AuthTokensModel?
      _cachedTokens; // Cache tokens in memory to avoid storage read timing issues

  ApiClient(this._authLocalDataSource) {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add interceptors
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final skipAuthHeader = options.headers['X-Skip-Auth'];
        final skipAuth = skipAuthHeader == true || skipAuthHeader == 'true';
        if (skipAuth) {
          options.headers.remove('X-Skip-Auth');
          return handler.next(options);
        }

        // Use cached tokens first, fallback to storage
        _cachedTokens ??= await _authLocalDataSource.getTokens();
        final tokens = _cachedTokens;

        print('🔐 API Request: ${options.method} ${options.path}');
        if (tokens != null && !tokens.isExpired) {
          final token = tokens.accessToken;
          print(
              '🔐 Token available: true (expires in ${tokens.remainingSeconds}s)');
          print(
              '🔐 Token (first 20 chars): ${token.substring(0, token.length > 20 ? 20 : token.length)}...');
          options.headers['Authorization'] = 'Bearer $token';
          print('🔐 Authorization header set');
        } else {
          print('🔐 WARNING: No valid token found!');
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // Handle 401 - token expired
        if (error.response?.statusCode == 401) {
          print('🔄 401 detected - Need to refresh token');

          // If already refreshing, wait for it to complete
          if (_isRefreshing) {
            print('🔄 Already refreshing, waiting...');
            // Wait a bit and retry
            await Future.delayed(Duration(milliseconds: 100));

            // Check if tokens were updated (use cached tokens)
            final tokens = _cachedTokens;
            if (tokens != null && !tokens.isExpired) {
              print('✅ Token refreshed by another request, retrying...');
              error.requestOptions.headers['Authorization'] =
                  'Bearer ${tokens.accessToken}';
              try {
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                print('❌ Retry failed: $e');
              }
            }
            return handler.next(error);
          }

          // Set the lock
          _isRefreshing = true;
          print('🔄 Starting token refresh...');

          try {
            // Try to refresh token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Use cached tokens (already updated in _refreshToken)
              final tokens = _cachedTokens;
              if (tokens != null && !tokens.isExpired) {
                print('✅ Retrying original request with new token');
                error.requestOptions.headers['Authorization'] =
                    'Bearer ${tokens.accessToken}';
                final response = await _dio.fetch(error.requestOptions);
                return handler.resolve(response);
              }
            }
          } finally {
            // Release the lock
            _isRefreshing = false;
            print('🔄 Token refresh completed, lock released');
          }
        }
        return handler.next(error);
      },
    ));
  }

  Future<bool> _refreshToken() async {
    try {
      print('🔄 Attempting to refresh token...');
      final tokens = await _authLocalDataSource.getTokens();
      if (tokens == null) {
        print('❌ REFRESH FAILED: No tokens found in local storage');
        return false;
      }

      print(
          '🔄 Sending refresh request with token (first 20 chars): ${tokens.refreshToken.substring(0, 20)}...');
      final response = await _dio.post(
        ApiConfig.refreshTokenEndpoint,
        data: {'refresh_token': tokens.refreshToken},
      );

      if (response.statusCode == 200) {
        print('✅ Refresh successful! Saving new tokens...');
        // Save new tokens using the existing model structure
        final accessToken = response.data['access_token'] as String;
        final refreshToken = response.data['refresh_token'] as String;
        final expiresIn = response.data['expires_in'] as int? ?? 3600;

        final newTokens = AuthTokensModel(
          accessToken: accessToken,
          refreshToken: refreshToken,
          expiresIn: expiresIn,
          expiryTime: DateTime.now().add(Duration(seconds: expiresIn)),
        );

        // Update cache immediately (before storage write completes)
        _cachedTokens = newTokens;
        print('✅ Tokens cached in memory');

        // Save to storage (async, may take time)
        await _authLocalDataSource.saveTokens(newTokens);
        print('✅ New tokens saved to local storage');
        return true;
      }
      print('❌ REFRESH FAILED: Unexpected status code ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ REFRESH FAILED: Exception caught - $e');
      if (e is DioException) {
        print(
            '❌ DioException details: ${e.response?.statusCode} - ${e.response?.data}');
      }
      return false;
    }
  }

  // GET request
  Future<Response> get(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  // Public GET request (no auth)
  Future<Response> getPublic(String path,
      {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(
      path,
      queryParameters: queryParameters,
      options: Options(headers: {'X-Skip-Auth': 'true'}),
    );
  }

  // POST request
  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  // PUT request
  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  // PATCH request
  Future<Response> patch(String path, {dynamic data}) async {
    return await _dio.patch(path, data: data);
  }

  // DELETE request
  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }

  // Upload file
  Future<Response> uploadFile(String path, FormData formData) async {
    return await _dio.post(path, data: formData);
  }

  // Clear cached tokens (call this on logout)
  void clearCachedTokens() {
    _cachedTokens = null;
    print('🔐 Cached tokens cleared');
  }
}
