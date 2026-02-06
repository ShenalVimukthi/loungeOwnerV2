import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';

/// Remote data source for lounge owner registration operations
/// Makes HTTP requests to backend API
class LoungeOwnerRemoteDataSource {
  final ApiClient apiClient;

  LoungeOwnerRemoteDataSource({required this.apiClient});

  /// Save business and manager information (Step 1)
  /// POST /api/v1/lounge-owner/register/business-info
  Future<void> saveBusinessInfo({
    required String businessName,
    required String businessLicense,
    required String managerFullName,
    required String managerNicNumber,
    required String managerEmail,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/v1/lounge-owner/register/business-info',
        data: {
          'business_name': businessName,
          'business_license': businessLicense,
          'manager_full_name': managerFullName,
          'manager_nic_number': managerNicNumber,
          'manager_email': managerEmail,
        },
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to save business and manager info');
      }
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Upload Manager NIC images with OCR validation (Step 2)
  /// POST /api/v1/lounge-owner/register/upload-manager-nic
  Future<Map<String, dynamic>> uploadManagerNIC({
    required String managerNicNumber,
    required String managerNicFrontUrl,
    required String managerNicBackUrl,
    required String ocrExtractedText,
    required bool ocrMatched,
  }) async {
    try {
      final response = await apiClient.post(
        '/api/v1/lounge-owner/register/upload-manager-nic',
        data: {
          'manager_nic_number': managerNicNumber,
          'manager_nic_front_url': managerNicFrontUrl,
          'manager_nic_back_url': managerNicBackUrl,
          'ocr_extracted': ocrExtractedText,
          'ocr_matched': ocrMatched,
        },
      );

      if (response.statusCode != 200) {
        throw ServerException('Failed to upload Manager NIC images');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Get registration progress
  /// GET /api/v1/lounge-owner/registration/progress
  Future<Map<String, dynamic>> getRegistrationProgress() async {
    try {
      final response = await apiClient.get('/api/v1/lounge-owner/registration/progress');

      if (response.statusCode != 200) {
        throw ServerException('Failed to get registration progress');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Get lounge owner profile
  /// GET /api/v1/lounge-owner/profile
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await apiClient.get('/api/v1/lounge-owner/profile');

      if (response.statusCode != 200) {
        throw ServerException('Failed to get profile');
      }

      final data = response.data as Map<String, dynamic>;
      
      // 🔍 DEBUG: Log FULL JSON response
      print('🔍 API RESPONSE /lounge-owner/profile FULL JSON:');
      data.forEach((key, value) {
        print('   $key: $value (${value.runtimeType})');
      });
      
      return data;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Check if OCR is blocked
  /// Returns ocr_blocked_until timestamp if blocked, null if not blocked
  Future<String?> checkOCRBlock() async {
    try {
      final progress = await getRegistrationProgress();
      return progress['ocr_blocked_until'] as String?;
    } catch (e) {
      throw ServerException( e.toString());
    }
  }
}
