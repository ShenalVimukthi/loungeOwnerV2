import '../../core/network/api_client.dart';
import '../../core/error/exceptions.dart';
import '../models/route_model.dart';

/// Remote data source for route operations
class RouteRemoteDataSource {
  final ApiClient apiClient;

  RouteRemoteDataSource({required this.apiClient});

  /// Get all master routes
  /// GET /api/v1/master-routes
  Future<List<MasterRoute>> getMasterRoutes() async {
    try {
      final response = await apiClient.get('/api/v1/master-routes');

      print('📍 Master Routes Response Status: ${response.statusCode}');
      print('📍 Master Routes Response Type: ${response.data.runtimeType}');
      print('📍 Master Routes Response Data: ${response.data}');

      if (response.statusCode != 200) {
        throw ServerException('Failed to get master routes');
      }

      // Handle both direct array and wrapped response
      final responseData = response.data;
      
      if (responseData is Map<String, dynamic>) {
        // Response is wrapped in an object like {master_routes: [...]} or {routes: [...]}
        print('📍 Response is Map, keys: ${responseData.keys}');
        
        // Try different keys the backend might use - use safe extraction
        List<dynamic> data = [];
        if (responseData.containsKey('master_routes') && responseData['master_routes'] is List) {
          data = responseData['master_routes'] as List;
          print('📍 Found master_routes key with ${data.length} items');
        } else if (responseData.containsKey('routes') && responseData['routes'] is List) {
          data = responseData['routes'] as List;
          print('📍 Found routes key with ${data.length} items');
        } else if (responseData.containsKey('data') && responseData['data'] is List) {
          data = responseData['data'] as List;
          print('📍 Found data key with ${data.length} items');
        } else {
          print('📍 No known list key found in response');
        }
        
        print('📍 Extracted ${data.length} routes from map');
        return data.map((e) => MasterRoute.fromJson(e as Map<String, dynamic>)).toList();
      } else if (responseData is List) {
        // Response is a direct array
        print('📍 Response is direct List with ${responseData.length} items');
        return responseData.map((e) => MasterRoute.fromJson(e as Map<String, dynamic>)).toList();
      } else {
        print('❌ Unexpected response type: ${responseData.runtimeType}');
        throw ServerException('Unexpected response format: ${responseData.runtimeType}');
      }
    } catch (e, stackTrace) {
      print('❌ Get Master Routes Error: $e');
      print('❌ Stack trace: $stackTrace');
      throw ServerException(e.toString());
    }
  }

  /// Get stops for a specific route
  /// GET /api/v1/master-routes/:routeId - Returns route details with stops
  Future<List<MasterRouteStop>> getRouteStops(String routeId) async {
    try {
      // Backend returns: {"route": {...}, "stops": [...]}
      final response = await apiClient.get('/api/v1/master-routes/$routeId');

      if (response.statusCode != 200) {
        throw ServerException('Failed to get route stops');
      }

      // Extract stops from wrapped response
      final responseData = response.data;
      
      if (responseData is Map<String, dynamic>) {
        // Response is: {"route": {...}, "stops": [...]}
        final stops = responseData['stops'];
        if (stops is List) {
          return stops.map((e) => MasterRouteStop.fromJson(e as Map<String, dynamic>)).toList();
        }
      }
      
      if (responseData is List) {
        // Fallback: Response is a direct array
        return responseData.map((e) => MasterRouteStop.fromJson(e as Map<String, dynamic>)).toList();
      }
      
      throw ServerException('Unexpected response format for stops');
    } catch (e) {
      print('❌ Get Route Stops Error: $e');
      throw ServerException(e.toString());
    }
  }
}
