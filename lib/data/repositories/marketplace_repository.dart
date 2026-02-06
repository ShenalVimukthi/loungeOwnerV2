import '../../domain/entities/lounge_product.dart';
import '../../domain/entities/marketplace_category.dart';
import '../datasources/marketplace_remote_datasource.dart';
import '../models/lounge_product_model.dart';

/// Repository interface for marketplace operations
abstract class MarketplaceRepository {
  /// Get all marketplace categories
  Future<List<MarketplaceCategory>> getCategories();

  /// Get products for a specific lounge
  Future<List<LoungeProduct>> getProductsByLoungeId(String loungeId);

  /// Get a single product by ID
  Future<LoungeProduct> getProductById(String loungeId, String productId);

  /// Create a new product
  Future<LoungeProduct> createProduct(String loungeId, LoungeProduct product);

  /// Update an existing product
  Future<LoungeProduct> updateProduct(String loungeId, LoungeProduct product);

  /// Delete a product
  Future<void> deleteProduct(String loungeId, String productId);
}

/// Implementation of marketplace repository
class MarketplaceRepositoryImpl implements MarketplaceRepository {
  final MarketplaceRemoteDataSource _remoteDataSource;

  MarketplaceRepositoryImpl({required MarketplaceRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<MarketplaceCategory>> getCategories() async {
    final categoryModels = await _remoteDataSource.getCategories();
    return categoryModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<LoungeProduct>> getProductsByLoungeId(String loungeId) async {
    final productModels = await _remoteDataSource.getProductsByLoungeId(loungeId);
    return productModels.map((model) => model.toEntity()).toList();
  }

  @override
  Future<LoungeProduct> getProductById(String loungeId, String productId) async {
    final productModel = await _remoteDataSource.getProductById(loungeId, productId);
    return productModel.toEntity();
  }

  @override
  Future<LoungeProduct> createProduct(String loungeId, LoungeProduct product) async {
    final productModel = LoungeProductModel.fromEntity(product);
    final createdModel = await _remoteDataSource.createProduct(
      loungeId,
      productModel.toCreateJson(),
    );
    return createdModel.toEntity();
  }

  @override
  Future<LoungeProduct> updateProduct(String loungeId, LoungeProduct product) async {
    final productModel = LoungeProductModel.fromEntity(product);
    final updatedModel = await _remoteDataSource.updateProduct(
      loungeId,
      product.id,
      productModel.toJson(),
    );
    return updatedModel.toEntity();
  }

  @override
  Future<void> deleteProduct(String loungeId, String productId) async {
    await _remoteDataSource.deleteProduct(loungeId, productId);
  }
}
