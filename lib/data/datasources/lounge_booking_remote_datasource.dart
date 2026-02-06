import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/lounge_booking_model.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../../config/api_config.dart';

/// Remote Data Source: Lounge Booking API
/// Handles all lounge booking-related API calls according to backend documentation
abstract class LoungeBookingRemoteDataSource {
  /// Get bookings for lounge owner
  /// GET /api/v1/lounge-bookings/owner
  Future<List<LoungeBookingModel>> getOwnerBookings({
    String? loungeId,
    String? status,
    String? date,
  });

  /// Get today's bookings (Staff view)
  /// GET /api/v1/lounge-bookings/today
  Future<List<LoungeBookingModel>> getTodayBookings();

  /// Get my bookings (Passenger view)
  /// GET /api/v1/lounge-bookings/my-bookings
  Future<List<LoungeBookingModel>> getMyBookings({
    String? status,
    int? page,
  });

  /// Get upcoming bookings (Passenger view)
  /// GET /api/v1/lounge-bookings/upcoming
  Future<List<LoungeBookingModel>> getUpcomingBookings();

  /// Get booking by ID
  /// GET /api/v1/lounge-bookings/:booking_id
  Future<LoungeBookingModel> getBookingById(String bookingId);

  /// Get booking by reference
  /// GET /api/v1/lounge-bookings/reference/:reference
  Future<LoungeBookingModel> getBookingByReference(String reference);
}

class LoungeBookingRemoteDataSourceImpl
    implements LoungeBookingRemoteDataSource {
  final ApiClient apiClient;
  late final Dio _loungeDio;
  final _secureStorage = const FlutterSecureStorage();

  LoungeBookingRemoteDataSourceImpl({required this.apiClient}) {
    _loungeDio = Dio(BaseOptions(
      baseUrl: ApiConfig.getLoungeBaseUrl(),
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    _loungeDio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _secureStorage.read(key: 'access_token');
        if (token != null) {
          options.headers['Authorization'] = 'Bearer \$token';
        }
        return handler.next(options);
      },
    ));
  }

  @override
  Future<List<LoungeBookingModel>> getOwnerBookings({
    String? loungeId,
    String? status,
    String? date,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (loungeId != null) queryParameters['lounge_id'] = loungeId;
      if (status != null) queryParameters['status'] = status;
      if (date != null) queryParameters['date'] = date;

      final response = await _loungeDio.get(
        '/api/v1/lounge-bookings/owner',
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        throw const ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          null,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final lounges = data['lounges'] as List<dynamic>? ?? [];

      // Flatten bookings from all lounges
      final allBookings = <LoungeBookingModel>[];
      for (final lounge in lounges) {
        final loungeData = lounge as Map<String, dynamic>;
        final bookings = loungeData['bookings'] as List<dynamic>? ?? [];
        final loungeName = loungeData['lounge_name'] as String?;

        for (final booking in bookings) {
          final bookingMap = booking as Map<String, dynamic>;
          // Add lounge_name to each booking for convenience
          bookingMap['lounge_name'] = loungeName;
          allBookings.add(LoungeBookingModel.fromJson(bookingMap));
        }
      }

      return allBookings;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<LoungeBookingModel>> getTodayBookings() async {
    try {
      final response = await _loungeDio.get('/api/v1/lounge-bookings/today');

      if (response.data == null) {
        throw const ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          null,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final bookingsList = data['bookings'] as List<dynamic>? ?? [];

      return bookingsList
          .map((json) =>
              LoungeBookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<LoungeBookingModel>> getMyBookings({
    String? status,
    int? page,
  }) async {
    try {
      final queryParameters = <String, dynamic>{};
      if (status != null) queryParameters['status'] = status;
      if (page != null) queryParameters['page'] = page;

      final response = await _loungeDio.get(
        '/api/v1/lounge-bookings/my-bookings',
        queryParameters: queryParameters,
      );

      if (response.data == null) {
        throw const ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          null,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final bookingsList = data['bookings'] as List<dynamic>? ?? [];

      return bookingsList
          .map((json) =>
              LoungeBookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<LoungeBookingModel>> getUpcomingBookings() async {
    try {
      final response = await _loungeDio.get('/api/v1/lounge-bookings/upcoming');

      if (response.data == null) {
        throw const ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          null,
        );
      }

      final data = response.data as Map<String, dynamic>;
      final bookingsList = data['bookings'] as List<dynamic>? ?? [];

      return bookingsList
          .map((json) =>
              LoungeBookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<LoungeBookingModel> getBookingById(String bookingId) async {
    try {
      final response =
          await _loungeDio.get('/api/v1/lounge-bookings/$bookingId');

      if (response.data == null) {
        throw const ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          null,
        );
      }

      return LoungeBookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<LoungeBookingModel> getBookingByReference(String reference) async {
    try {
      final response =
          await _loungeDio.get('/api/v1/lounge-bookings/reference/$reference');

      if (response.data == null) {
        throw const ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          null,
        );
      }

      return LoungeBookingModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio errors and convert to app exceptions
  AppException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.sendTimeout) {
      return const NetworkException('Connection timeout');
    }

    if (error.type == DioExceptionType.connectionError) {
      return const NetworkException('No internet connection');
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
      } else if (statusCode == 404) {
        return ServerException(message, code ?? 'NOT_FOUND', statusCode);
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
