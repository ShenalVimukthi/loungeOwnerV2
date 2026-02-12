import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/driver_model.dart';
import '../../core/error/exceptions.dart';
import '../../config/api_config.dart';

/// Remote Data Source: Driver API
/// Handles all driver-related API calls
abstract class DriverRemoteDataSource {
  /// Add driver to lounge (Lounge Owner only)
  /// POST /api/v1/lounges/drivers
  Future<DriverModel> addDriver({
    required String loungeId,
    required String fullName,
    required String nicNumber,
    required String contactNumber,
    required String vehicleNumber,
    required String vehicleType,
  });

  /// Get all drivers for a lounge
  /// GET /api/v1/lounges/:lounge_id/drivers
  Future<List<DriverModel>> getDriversByLounge({
    required String loungeId,
  });
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  late final Dio _dio;
  final _secureStorage = const FlutterSecureStorage();

  DriverRemoteDataSourceImpl() {
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
          print('🔐 Driver API: Token added to request');
        } else {
          print('⚠️ Driver API: No token found in storage');
        }
        return handler.next(options);
      },
    ));
  }

  @override
  Future<DriverModel> addDriver({
    required String loungeId,
    required String fullName,
    required String nicNumber,
    required String contactNumber,
    required String vehicleNumber,
    required String vehicleType,
  }) async {
    try {
      print('📤 [DRIVER API] Adding driver to lounge: $loungeId');
      print(
          '📤 [DRIVER API] Driver data: name=$fullName, nic=$nicNumber, vehicle=$vehicleNumber, type=$vehicleType');

      final response = await _dio.post(
        '/api/v1/lounges/drivers',
        data: {
          'lounge_id': loungeId,
          'name': fullName,
          'nic_number': nicNumber, // Backend expects nic_number not nic
          'contact_no': contactNumber,
          'vehicle_no': vehicleNumber,
          'vehicle_type': vehicleType,
        },
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

      // Handle different response formats
      final responseData = response.data;
      if (responseData is Map<String, dynamic>) {
        final driverData =
            responseData['driver'] ?? responseData['data'] ?? responseData;
        return DriverModel.fromJson(driverData as Map<String, dynamic>);
      }

      return DriverModel.fromJson(responseData as Map<String, dynamic>);
    } on DioException catch (e) {
      print('❌ DioException: ${e.message}');
      print('❌ Response: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e) {
      print('❌ Unexpected error: $e');
      rethrow;
    }
  }

  @override
  Future<List<DriverModel>> getDriversByLounge({
    required String loungeId,
  }) async {
    try {
      print('📤 [DRIVER API] Fetching drivers for lounge: $loungeId');
      final response = await _dio.get('/api/v1/lounges/$loungeId/drivers');

      print('📥 [DRIVER API] Response status: ${response.statusCode}');
      print('📥 [DRIVER API] Response data type: ${response.data.runtimeType}');
      print('📥 [DRIVER API] Response data: ${response.data}');

      if (response.data == null) {
        throw const ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          null,
        );
      }

      final driverList = _extractDriverList(response.data);
      print('✅ [DRIVER API] Parsed ${driverList.length} drivers');
      return driverList.map((json) => DriverModel.fromJson(json)).toList();
    } on DioException catch (e) {
      print('❌ [DRIVER API] DioException: ${e.message}');
      print('❌ [DRIVER API] Response: ${e.response?.data}');
      throw _handleDioError(e);
    } catch (e, stackTrace) {
      print('❌ [DRIVER API] Parse error: $e');
      print('❌ [DRIVER API] Stack trace: $stackTrace');
      throw const ServerException(
        'Failed to parse driver data from response',
        'PARSE_ERROR',
      );
    }
  }

  List<Map<String, dynamic>> _extractDriverList(dynamic responseData) {
    print(
        '📤 [DRIVER API] Extracting driver list from: ${responseData.runtimeType}');

    // Handle direct array response
    if (responseData is List) {
      print(
          '📤 [DRIVER API] Response is a direct List with ${responseData.length} items');
      return responseData.whereType<Map<String, dynamic>>().toList();
    }

    // Handle Map response with various possible keys
    if (responseData is Map<String, dynamic>) {
      print(
          '📤 [DRIVER API] Response is a Map with keys: ${responseData.keys.join(", ")}');

      // Try common wrapper keys
      final dynamic unwrapped = responseData['drivers'] ??
          responseData['data'] ??
          responseData['result'] ??
          responseData['items'];

      if (unwrapped is List) {
        print(
            '📤 [DRIVER API] Found list in wrapper with ${unwrapped.length} items');
        return unwrapped.whereType<Map<String, dynamic>>().toList();
      }

      // Check if the map itself contains nested data
      if (unwrapped is Map<String, dynamic>) {
        final dynamic nestedList =
            unwrapped['drivers'] ?? unwrapped['data'] ?? unwrapped['items'];
        if (nestedList is List) {
          print(
              '📤 [DRIVER API] Found list in nested wrapper with ${nestedList.length} items');
          return nestedList.whereType<Map<String, dynamic>>().toList();
        }
      }
    }

    print('❌ [DRIVER API] Could not extract driver list from response');
    print('❌ [DRIVER API] Response structure: $responseData');
    throw const ServerException(
      'Failed to parse driver data from response',
      'PARSE_ERROR',
    );
  }

  AppException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException(
        'Connection timeout. Please check if the backend server is running on http://10.0.2.2:8080',
      );
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException(
        'Cannot connect to the server. Please check if the backend is running.',
      );
    }

    final response = error.response;
    if (response != null) {
      final data = response.data;
      String message = 'Server error occurred';

      if (data is Map<String, dynamic>) {
        message = data['message'] ?? data['error'] ?? message;
      }

      return ServerException(
        message,
        'HTTP_${response.statusCode}',
        response.statusCode,
      );
    }

    return NetworkException('Network error: ${error.message}');
  }
}
