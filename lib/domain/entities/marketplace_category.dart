import 'package:equatable/equatable.dart';

/// Entity representing a marketplace product category
class MarketplaceCategory extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? iconName;
  final String? iconUrl;
  final String? parentCategoryId;
  final int displayOrder;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MarketplaceCategory({
    required this.id,
    required this.name,
    this.description,
    this.iconName,
    this.iconUrl,
    this.parentCategoryId,
    this.displayOrder = 0,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        iconName,
        iconUrl,
        parentCategoryId,
        displayOrder,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// Check if this is a root category (no parent)
  bool get isRootCategory => parentCategoryId == null;

  MarketplaceCategory copyWith({
    String? id,
    String? name,
    String? description,
    String? iconName,
    String? iconUrl,
    String? parentCategoryId,
    int? displayOrder,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MarketplaceCategory(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      iconName: iconName ?? this.iconName,
      iconUrl: iconUrl ?? this.iconUrl,
      parentCategoryId: parentCategoryId ?? this.parentCategoryId,
      displayOrder: displayOrder ?? this.displayOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
