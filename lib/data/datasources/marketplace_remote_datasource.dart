import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../../core/utils/logger.dart';
import '../models/lounge_product_model.dart';
import '../models/marketplace_category_model.dart';

/// Remote data source for marketplace operations
abstract class MarketplaceRemoteDataSource {
  /// Get all marketplace categories
  Future<List<MarketplaceCategoryModel>> getCategories();

  /// Get products for a specific lounge
  Future<List<LoungeProductModel>> getProductsByLoungeId(String loungeId);

  /// Get a single product by ID
  Future<LoungeProductModel> getProductById(String loungeId, String productId);

  /// Create a new product
  Future<LoungeProductModel> createProduct(
    String loungeId,
    Map<String, dynamic> productData,
  );

  /// Update an existing product
  Future<LoungeProductModel> updateProduct(
    String loungeId,
    String productId,
    Map<String, dynamic> productData,
  );

  /// Delete a product
  Future<void> deleteProduct(String loungeId, String productId);
}

/// Implementation of marketplace remote data source
class MarketplaceRemoteDataSourceImpl implements MarketplaceRemoteDataSource {
  final ApiClient _apiClient;

  MarketplaceRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<List<MarketplaceCategoryModel>> getCategories() async {
    try {
      AppLogger.info('Fetching marketplace categories');
      final response = await _apiClient.get('/api/v1/lounge-marketplace/categories');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['categories'] ?? response.data['data'] ?? [];
        final categories = data
            .map((json) => MarketplaceCategoryModel.fromJson(json as Map<String, dynamic>))
            .toList();
        AppLogger.info('Successfully fetched ${categories.length} categories');
        return categories;
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch categories',
      );
    } catch (e) {
      AppLogger.error('Error fetching marketplace categories', e);
      rethrow;
    }
  }

  @override
  Future<List<LoungeProductModel>> getProductsByLoungeId(String loungeId) async {
    try {
      AppLogger.info('Fetching products for lounge: $loungeId');
      final response = await _apiClient.get('/api/v1/lounges/$loungeId/products');
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['products'] ?? response.data['data'] ?? [];
        final products = data
            .map((json) => LoungeProductModel.fromJson(json as Map<String, dynamic>))
            .toList();
        AppLogger.info('Successfully fetched ${products.length} products');
        return products;
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch products',
      );
    } catch (e) {
      AppLogger.error('Error fetching products for lounge $loungeId', e);
      rethrow;
    }
  }

  @override
  Future<LoungeProductModel> getProductById(String loungeId, String productId) async {
    try {
      AppLogger.info('Fetching product: $productId from lounge: $loungeId');
      final response = await _apiClient.get('/api/v1/lounges/$loungeId/products/$productId');
      
      if (response.statusCode == 200) {
        final data = response.data['product'] ?? response.data['data'] ?? response.data;
        final product = LoungeProductModel.fromJson(data as Map<String, dynamic>);
        AppLogger.info('Successfully fetched product: ${product.name}');
        return product;
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to fetch product',
      );
    } catch (e) {
      AppLogger.error('Error fetching product $productId', e);
      rethrow;
    }
  }

  @override
  Future<LoungeProductModel> createProduct(
    String loungeId,
    Map<String, dynamic> productData,
  ) async {
    try {
      AppLogger.info('Creating product for lounge: $loungeId');
      AppLogger.debug('Product data: $productData');
      
      final response = await _apiClient.post(
        '/api/v1/lounges/$loungeId/products',
        data: productData,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data['product'] ?? response.data['data'] ?? response.data;
        final product = LoungeProductModel.fromJson(data as Map<String, dynamic>);
        AppLogger.info('Successfully created product: ${product.name}');
        return product;
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to create product',
      );
    } catch (e) {
      AppLogger.error('Error creating product', e);
      rethrow;
    }
  }

  @override
  Future<LoungeProductModel> updateProduct(
    String loungeId,
    String productId,
    Map<String, dynamic> productData,
  ) async {
    try {
      AppLogger.info('Updating product: $productId for lounge: $loungeId');
      AppLogger.debug('Update data: $productData');
      
      final response = await _apiClient.put(
        '/api/v1/lounges/$loungeId/products/$productId',
        data: productData,
      );
      
      if (response.statusCode == 200) {
        final data = response.data['product'] ?? response.data['data'] ?? response.data;
        final product = LoungeProductModel.fromJson(data as Map<String, dynamic>);
        AppLogger.info('Successfully updated product: ${product.name}');
        return product;
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to update product',
      );
    } catch (e) {
      AppLogger.error('Error updating product $productId', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteProduct(String loungeId, String productId) async {
    try {
      AppLogger.info('Deleting product: $productId from lounge: $loungeId');
      
      final response = await _apiClient.delete(
        '/api/v1/lounges/$loungeId/products/$productId',
      );
      
      if (response.statusCode == 200 || response.statusCode == 204) {
        AppLogger.info('Successfully deleted product: $productId');
        return;
      }
      
      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Failed to delete product',
      );
    } catch (e) {
      AppLogger.error('Error deleting product $productId', e);
      rethrow;
    }
  }
}
