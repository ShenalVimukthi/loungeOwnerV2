import 'package:dio/dio.dart';
import '../models/staff_model.dart';
import '../models/user_model.dart';
import '../../core/error/exceptions.dart';

/// Remote Data Source: Staff API
/// Handles all staff-related API calls
abstract class StaffRemoteDataSource {
  Future<StaffModel> registerStaff({
    required String userId,
    required String staffType,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    required int experienceYears,
    required String emergencyContact,
    required String emergencyContactName,
    String? busOwnerCode,
    String? busRegistrationNumber,
  });

  Future<StaffProfileRemoteResult> getStaffProfile();

  Future<StaffModel> updateStaffProfile({
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    int? experienceYears,
    String? emergencyContact,
    String? emergencyContactName,
  });
}

class StaffRemoteDataSourceImpl implements StaffRemoteDataSource {
  final Dio dio;
  final String baseUrl;

  StaffRemoteDataSourceImpl({
    required this.dio,
    required this.baseUrl,
  });

  @override
  Future<StaffModel> registerStaff({
    required String userId,
    required String staffType,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    required int experienceYears,
    required String emergencyContact,
    required String emergencyContactName,
    String? busOwnerCode,
    String? busRegistrationNumber,
  }) async {
    try {
      final response = await dio.post(
        '$baseUrl/api/v1/staff/register',
        data: {
          'user_id': userId,
          'staff_type': staffType,
          if (licenseNumber != null) 'license_number': licenseNumber,
          if (licenseExpiryDate != null)
            'license_expiry_date': licenseExpiryDate.toIso8601String().split('T')[0],
          'experience_years': experienceYears,
          'emergency_contact': emergencyContact,
          'emergency_contact_name': emergencyContactName,
          if (busOwnerCode != null) 'bus_owner_code': busOwnerCode,
          if (busRegistrationNumber != null)
            'bus_registration_number': busRegistrationNumber,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw ServerException(
          'Failed to register staff',
          'STAFF_REGISTRATION_FAILED',
          response.statusCode,
        );
      }

      // Backend might return staff object directly or wrapped in 'staff' key
      final data = response.data;

      if (data == null) {
        throw ServerException(
          'Empty response from server',
          'EMPTY_RESPONSE',
          response.statusCode,
        );
      }

      // Handle both response formats: {staff: {...}} or {...}
      if (data is Map<String, dynamic>) {
        if (data.containsKey('staff')) {
          return StaffModel.fromJson(data['staff'] as Map<String, dynamic>);
        } else {
          return StaffModel.fromJson(data);
        }
      }

      throw ServerException(
        'Invalid response format',
        'INVALID_RESPONSE_FORMAT',
        response.statusCode,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<StaffProfileRemoteResult> getStaffProfile() async {
    try {
      final response = await dio.get('$baseUrl/api/v1/staff/profile');

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to get staff profile',
          'GET_STAFF_PROFILE_FAILED',
          response.statusCode,
        );
      }

      final data = response.data as Map<String, dynamic>;

      return StaffProfileRemoteResult(
        user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
        staff: data['staff'] != null
            ? StaffModel.fromJson(data['staff'] as Map<String, dynamic>)
            : null,
        busOwner: data['bus_owner'] as Map<String, dynamic>?,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  @override
  Future<StaffModel> updateStaffProfile({
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    int? experienceYears,
    String? emergencyContact,
    String? emergencyContactName,
  }) async {
    try {
      final response = await dio.put(
        '$baseUrl/api/v1/staff/profile',
        data: {
          if (licenseNumber != null) 'license_number': licenseNumber,
          if (licenseExpiryDate != null)
            'license_expiry_date': licenseExpiryDate.toIso8601String().split('T')[0],
          if (experienceYears != null) 'experience_years': experienceYears,
          if (emergencyContact != null) 'emergency_contact': emergencyContact,
          if (emergencyContactName != null)
            'emergency_contact_name': emergencyContactName,
        },
      );

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to update staff profile',
          'UPDATE_STAFF_PROFILE_FAILED',
          response.statusCode,
        );
      }

      final data = response.data as Map<String, dynamic>;
      return StaffModel.fromJson(data['staff'] as Map<String, dynamic>);
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

/// Result from remote staff profile fetch
class StaffProfileRemoteResult {
  final UserModel user;
  final StaffModel? staff;
  final Map<String, dynamic>? busOwner;

  StaffProfileRemoteResult({
    required this.user,
    this.staff,
    this.busOwner,
  });
}
