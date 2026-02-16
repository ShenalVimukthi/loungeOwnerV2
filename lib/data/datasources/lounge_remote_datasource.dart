import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/lounge_route_model.dart';

/// Remote data source for lounge operations
/// Makes HTTP requests to backend API
class LoungeRemoteDataSource {
  final ApiClient apiClient;

  LoungeRemoteDataSource({required this.apiClient});

  /// Add a new lounge (Step 3)
  /// POST /api/v1/lounge-owner/register/add-lounge
  Future<Map<String, dynamic>> addLounge({
    required String loungeName,
    required String address,
    required String city, // Legacy parameter, send empty
    required String state,
    required String postalCode,
    String? district,
    required double latitude,
    required double longitude,
    required String contactPersonName, // Legacy
    required String businessEmail, // Legacy
    required String businessPhone,
    required String description,
    required List<String> loungePhotos,
    required List<String> facilities,
    required Map<String, dynamic> operatingHours, // Legacy
    int? capacity,
    String? price1Hour,
    String? price2Hours,
    String? price3Hours,
    String? priceUntilBus,
    // Routes that the lounge serves (array of route-stop combinations)
    required List<LoungeRouteModel> routes,
  }) async {
    try {
      final data = {
        'lounge_name': loungeName,
        'address': address,
        'contact_phone': businessPhone.isEmpty ? '0000000000' : businessPhone,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
        'amenities': facilities,
        'images': loungePhotos,
        'routes': routes.map((r) => r.toJson()).toList(),
      };

      // Add optional fields if provided
      if (capacity != null) data['capacity'] = capacity;
      if (price1Hour != null) data['price_1_hour'] = price1Hour;
      if (price2Hours != null) data['price_2_hours'] = price2Hours;
      if (price3Hours != null) data['price_3_hours'] = price3Hours;
      if (priceUntilBus != null) data['price_until_bus'] = priceUntilBus;
      if (description.isNotEmpty) data['description'] = description;
      if (state.isNotEmpty) data['state'] = state;
      if (postalCode.isNotEmpty) data['postal_code'] = postalCode;
      if (district != null && district.isNotEmpty) data['district'] = district;

      // Debug: Print full request data
      print('📍 Add Lounge Request Data:');
      print('   lounge_name: ${data['lounge_name']}');
      print('   address: ${data['address']}');
      print('   contact_phone: ${data['contact_phone']}');
      print('   latitude: ${data['latitude']}');
      print('   longitude: ${data['longitude']}');
      print('   capacity: ${data['capacity']}');
      print('   amenities: ${data['amenities']}');
      print('   images count: ${(data['images'] as List).length}');
      print('   routes count: ${(data['routes'] as List).length}');
      print('   routes: ${data['routes']}');

      final response = await apiClient.post(
        '/api/v1/lounge-owner/register/add-lounge',
        data: data,
      );

      print('📍 Add Lounge Response Status: ${response.statusCode}');
      print('📍 Add Lounge Response Data: ${response.data}');

      if (response.statusCode != 201) {
        throw ServerException(
          'Failed to add lounge - Status: ${response.statusCode}',
        );
      }

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      print('❌ Add Lounge DioException: ${e.type}');
      print('❌ Response Status: ${e.response?.statusCode}');
      print('❌ Response Data: ${e.response?.data}');
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw ServerException('Add lounge failed: $errorMessage');
    } catch (e) {
      print('❌ Add Lounge Error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Get all lounges owned by the authenticated user
  /// GET /api/v1/lounges/my-lounges
  Future<List<Map<String, dynamic>>> getMyLounges() async {
    try {
      print('📍 Fetching my lounges...');
      final response = await apiClient.get('/api/v1/lounges/my-lounges');

      print('📍 GetMyLounges Response Status: ${response.statusCode}');
      print('📍 GetMyLounges Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to get lounges - Status: ${response.statusCode}',
        );
      }

      // Handle both array response and wrapped response
      final responseData = response.data;
      List<dynamic> loungesList;

      if (responseData is List) {
        loungesList = responseData;
      } else if (responseData is Map && responseData.containsKey('lounges')) {
        loungesList = responseData['lounges'] as List? ?? [];
      } else if (responseData is Map && responseData.containsKey('data')) {
        loungesList = responseData['data'] as List? ?? [];
      } else {
        print('⚠️ Unexpected response format: ${responseData.runtimeType}');
        loungesList = [];
      }

      print('📍 Parsed ${loungesList.length} lounges');
      return loungesList.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      print('❌ GetMyLounges DioException: ${e.type}');
      print('❌ Response Status: ${e.response?.statusCode}');
      print('❌ Response Data: ${e.response?.data}');
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw ServerException('Get lounges failed: $errorMessage');
    } catch (e) {
      print('❌ GetMyLounges Error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Get a specific lounge by ID
  /// GET /api/v1/lounges/:id
  Future<Map<String, dynamic>> getLoungeById(String id) async {
    try {
      final response = await apiClient.get('/api/v1/lounges/$id');

      if (response.statusCode != 200) {
        throw ServerException('Failed to get lounge');
      }

      return response.data as Map<String, dynamic>;
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  /// Get all registered lounges (for staff member selection)
  /// GET /api/v1/lounges
  Future<List<Map<String, dynamic>>> getAllLounges() async {
    try {
      print('📍 Fetching all lounges...');
      final response = await apiClient.get('/api/v1/lounges');

      print('📍 GetAllLounges Response Status: ${response.statusCode}');
      print('📍 GetAllLounges Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to get lounges - Status: ${response.statusCode}',
        );
      }

      // Handle both array response and wrapped response
      final responseData = response.data;
      List<dynamic> loungesList;

      if (responseData is List) {
        loungesList = responseData;
      } else if (responseData is Map && responseData.containsKey('lounges')) {
        loungesList = responseData['lounges'] as List? ?? [];
      } else if (responseData is Map && responseData.containsKey('data')) {
        loungesList = responseData['data'] as List? ?? [];
      } else {
        print('⚠️ Unexpected response format: ${responseData.runtimeType}');
        loungesList = [];
      }

      print('📍 Parsed ${loungesList.length} lounges');
      return loungesList.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      print('❌ GetAllLounges DioException: ${e.type}');
      print('❌ Response Status: ${e.response?.statusCode}');
      print('❌ Response Data: ${e.response?.data}');
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw ServerException('Get all lounges failed: $errorMessage');
    } catch (e) {
      print('❌ GetAllLounges Error: $e');
      throw ServerException(e.toString());
    }
  }

  /// Get active lounges for staff registration
  /// GET /api/v1/lounges/active
  /// Returns lounges with status='active' for staff member to select during registration
  Future<List<Map<String, dynamic>>> getActiveLounges() async {
    try {
      print('📍 Fetching active lounges...');
      final response = await apiClient.get('/api/v1/lounges/active');

      print('📍 GetActiveLounges Response Status: ${response.statusCode}');
      print('📍 GetActiveLounges Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException(
          'Failed to get active lounges - Status: ${response.statusCode}',
        );
      }

      // Handle both array response and wrapped response
      final responseData = response.data;
      List<dynamic> loungesList;

      if (responseData is List) {
        loungesList = responseData;
      } else if (responseData is Map && responseData.containsKey('lounges')) {
        loungesList = responseData['lounges'] as List? ?? [];
      } else if (responseData is Map && responseData.containsKey('data')) {
        loungesList = responseData['data'] as List? ?? [];
      } else {
        print('⚠️ Unexpected response format: ${responseData.runtimeType}');
        loungesList = [];
      }

      print('📍 Parsed ${loungesList.length} active lounges');
      return loungesList.map((e) => e as Map<String, dynamic>).toList();
    } on DioException catch (e) {
      print('❌ GetActiveLounges DioException: ${e.type}');
      print('❌ Response Status: ${e.response?.statusCode}');
      print('❌ Response Data: ${e.response?.data}');
      final errorMessage =
          e.response?.data?['message'] ?? e.message ?? 'Unknown error';
      throw ServerException('Get active lounges failed: $errorMessage');
    } catch (e) {
      print('❌ GetActiveLounges Error: $e');
      throw ServerException(e.toString());
    }
  }
}
