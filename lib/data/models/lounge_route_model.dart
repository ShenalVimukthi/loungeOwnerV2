import '../../domain/entities/lounge_route.dart';

/// Data model for LoungeRoute with JSON serialization
class LoungeRouteModel extends LoungeRoute {
  const LoungeRouteModel({
    super.id,
    super.loungeId,
    required super.masterRouteId,
    required super.stopBeforeId,
    required super.stopAfterId,
    super.createdAt,
    super.updatedAt,
  });

  /// Create from JSON (from API response)
  factory LoungeRouteModel.fromJson(Map<String, dynamic> json) {
    return LoungeRouteModel(
      id: json['id'] as String?,
      loungeId: json['lounge_id'] as String?,
      masterRouteId: json['master_route_id'] as String,
      stopBeforeId: json['stop_before_id'] as String,
      stopAfterId: json['stop_after_id'] as String,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert to JSON (for API request)
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (loungeId != null) 'lounge_id': loungeId,
      'master_route_id': masterRouteId,
      'stop_before_id': stopBeforeId,
      'stop_after_id': stopAfterId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Create from entity
  factory LoungeRouteModel.fromEntity(LoungeRoute entity) {
    return LoungeRouteModel(
      id: entity.id,
      loungeId: entity.loungeId,
      masterRouteId: entity.masterRouteId,
      stopBeforeId: entity.stopBeforeId,
      stopAfterId: entity.stopAfterId,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
