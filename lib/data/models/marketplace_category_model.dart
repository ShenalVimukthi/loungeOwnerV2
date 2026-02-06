import '../../domain/entities/marketplace_category.dart';

/// Model for marketplace category data from API
class MarketplaceCategoryModel extends MarketplaceCategory {
  const MarketplaceCategoryModel({
    required super.id,
    required super.name,
    super.description,
    super.iconName,
    super.iconUrl,
    super.parentCategoryId,
    super.displayOrder,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON
  factory MarketplaceCategoryModel.fromJson(Map<String, dynamic> json) {
    return MarketplaceCategoryModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? 'Unknown Category',
      description: json['description']?.toString(),
      iconName: json['icon_name']?.toString(),
      iconUrl: json['icon_url']?.toString(),
      parentCategoryId: json['parent_category_id']?.toString(),
      displayOrder: json['display_order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  /// Convert model to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      if (iconName != null) 'icon_name': iconName,
      if (iconUrl != null) 'icon_url': iconUrl,
      if (parentCategoryId != null) 'parent_category_id': parentCategoryId,
      'display_order': displayOrder,
      'is_active': isActive,
    };
  }

  /// Convert entity to model
  factory MarketplaceCategoryModel.fromEntity(MarketplaceCategory entity) {
    return MarketplaceCategoryModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      iconName: entity.iconName,
      iconUrl: entity.iconUrl,
      parentCategoryId: entity.parentCategoryId,
      displayOrder: entity.displayOrder,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Convert to entity
  MarketplaceCategory toEntity() {
    return MarketplaceCategory(
      id: id,
      name: name,
      description: description,
      iconName: iconName,
      iconUrl: iconUrl,
      parentCategoryId: parentCategoryId,
      displayOrder: displayOrder,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
