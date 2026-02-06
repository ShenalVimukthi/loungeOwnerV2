import '../../domain/entities/transport_location.dart';

class TransportLocationModel {
  final String id;
  final String loungeId;
  final String locationName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, double>? prices; // vehicle_type -> price

  TransportLocationModel({
    required this.id,
    required this.loungeId,
    required this.locationName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.prices,
  });

  factory TransportLocationModel.fromJson(Map<String, dynamic> json) {
    Map<String, double>? parsedPrices;
    if (json['prices'] != null) {
      parsedPrices = {};
      final pricesData = json['prices'] as Map<String, dynamic>;
      pricesData.forEach((key, value) {
        parsedPrices![key] = (value as num).toDouble();
      });
    }

    return TransportLocationModel(
      id: json['id'] as String,
      loungeId: json['lounge_id'] as String,
      locationName: json['location_name'] as String,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      prices: parsedPrices,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lounge_id': loungeId,
      'location_name': locationName,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (prices != null) 'prices': prices,
    };
  }

  TransportLocation toEntity() {
    return TransportLocation(
      id: id,
      loungeId: loungeId,
      locationName: locationName,
      isActive: isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
      prices: prices,
    );
  }

  factory TransportLocationModel.fromEntity(TransportLocation entity) {
    return TransportLocationModel(
      id: entity.id,
      loungeId: entity.loungeId,
      locationName: entity.locationName,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      prices: entity.prices,
    );
  }
}
