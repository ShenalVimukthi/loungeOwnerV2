import 'package:dio/dio.dart';
import '../models/transport_location_model.dart';
import '../../core/error/exceptions.dart';
import '../../config/api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class TransportLocationRemoteDataSource {
  /// GET /api/v1/lounges/:id/transport-locations
  Future<List<TransportLocationModel>> getTransportLocations(String loungeId);

  /// POST /api/v1/lounges/transport-locations
  Future<TransportLocationModel> addTransportLocation({
    required String loungeId,
    required String locationName,
  });

  /// PUT /api/v1/lounges/:id/transport-locations/:location_id
  Future<TransportLocationModel> updateTransportLocation({
    required String loungeId,
    required String locationId,
    required String locationName,
  });

  /// DELETE /api/v1/lounges/:id/transport-locations/:location_id
  Future<void> deleteTransportLocation({
    required String loungeId,
    required String locationId,
  });

  /// GET /api/v1/lounges/:id/transport-locations/:location_id/prices
  Future<Map<String, double>> getLocationPrices({
    required String loungeId,
    required String locationId,
  });

  /// POST /api/v1/lounges/:id/transport-locations/:location_id/prices
  Future<void> setLocationPrices({
    required String loungeId,
    required String locationId,
    required Map<String, double> prices,
  });
}

class TransportLocationRemoteDataSourceImpl
    implements TransportLocationRemoteDataSource {
  late final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  TransportLocationRemoteDataSourceImpl() {
    _dio = Dio(BaseOptions(
      baseUrl: ApiConfig.getLoungeBaseUrl(),
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Add auth interceptor
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print('🔐 Transport Location API: Token added to request');
        } else {
          print('⚠️ Transport Location API: No token found');
        }
        return handler.next(options);
      },
    ));
  }

  @override
  Future<List<TransportLocationModel>> getTransportLocations(
      String loungeId) async {
    try {
      print('📤 [API] Getting transport locations for lounge: $loungeId');

      final response = await _dio.get(
        '/api/v1/lounges/$loungeId/transport-locations',
      );

      print('📥 Response status: ${response.statusCode}');
      print('📥 Response data: ${response.data}');

      if (response.data == null) {
        throw const ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          null,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final locationsList = data['locations'] as List<dynamic>? ?? [];

      return locationsList
          .map((json) =>
              TransportLocationModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<TransportLocationModel> addTransportLocation({
    required String loungeId,
    required String locationName,
  }) async {
    try {
      print('📤 [API] Adding transport location: $locationName');
      print('📤 [API] Lounge ID: $loungeId');

      final response = await _dio.post(
        '/api/v1/lounges/transport-locations',
        data: {
          'LoungeID': loungeId,
          'Location': locationName,
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.data == null) {
        throw const ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          null,
        );
      }

      final locationData =
          response.data['location'] ?? response.data['data'] ?? response.data;
      return TransportLocationModel.fromJson(
          locationData as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<TransportLocationModel> updateTransportLocation({
    required String loungeId,
    required String locationId,
    required String locationName,
  }) async {
    try {
      print('📤 [API] Updating transport location: $locationId');

      final response = await _dio.put(
        '/api/v1/lounges/$loungeId/transport-locations/$locationId',
        data: {
          'location_name': locationName,
        },
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.data == null) {
        throw const ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          null,
        );
      }

      final locationData =
          response.data['location'] ?? response.data['data'] ?? response.data;
      return TransportLocationModel.fromJson(
          locationData as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteTransportLocation({
    required String loungeId,
    required String locationId,
  }) async {
    try {
      print('📤 [API] Deleting transport location: $locationId');

      final response = await _dio.delete(
        '/api/v1/lounges/$loungeId/transport-locations/$locationId',
      );

      print('📥 Response status: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<Map<String, double>> getLocationPrices({
    required String loungeId,
    required String locationId,
  }) async {
    try {
      print('📤 [API] Getting prices for location: $locationId');

      final response = await _dio.get(
        '/api/v1/lounges/$loungeId/transport-locations/$locationId/prices',
      );

      print('📥 Response status: ${response.statusCode}');

      if (response.data == null) {
        throw const ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          null,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final pricesData = data['prices'] as Map<String, dynamic>? ?? {};

      final prices = <String, double>{};
      pricesData.forEach((key, value) {
        prices[key] = (value as num).toDouble();
      });

      return prices;
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> setLocationPrices({
    required String loungeId,
    required String locationId,
    required Map<String, double> prices,
  }) async {
    try {
      print('📤 [API] Setting prices for location: $locationId');
      print('📤 [API] Prices: $prices');

      final response = await _dio.post(
        '/api/v1/lounges/$loungeId/transport-locations/$locationId/prices',
        data: {
          'prices': prices,
        },
      );

      print('📥 Response status: ${response.statusCode}');
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      throw _handleDioError(e);
    }
  }

  AppException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException(
        'Connection timeout. Please check if the backend server is running.',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException(
        'Cannot connect to server. Please ensure the backend is running and accessible.',
      );
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'An error occurred';
      String? code;

      if (data is Map<String, dynamic>) {
        message = data['message'] as String? ?? message;
        code = data['code'] as String? ?? data['error'] as String?;
      }

      if (statusCode == 401) {
        return AuthException(message, code);
      } else if (statusCode == 403) {
        return AuthException(message, code ?? 'FORBIDDEN');
      } else if (statusCode == 409) {
        return ServerException(
          message.isNotEmpty
              ? message
              : 'This location already exists or there is a conflict',
          code ?? 'CONFLICT',
          statusCode,
        );
      } else if (statusCode == 429) {
        return ServerException(message, code, statusCode);
      } else if (statusCode != null && statusCode >= 500) {
        return ServerException(message, code, statusCode);
      } else {
        return ServerException(message, code, statusCode);
      }
    }

    return NetworkException(error.message ?? 'Network error');
  }
}
