import '../../domain/entities/lounge.dart';
import 'lounge_route_model.dart';

class LoungeModel extends Lounge {
  const LoungeModel({
    required super.id,
    required super.loungeOwnerId,
    required super.loungeName,
    super.description,
    required super.address,
    super.state,
    super.country,
    super.postalCode,
    super.latitude,
    super.longitude,
    super.contactPhone,
    super.capacity,
    super.routes,
    super.price1Hour,
    super.price2Hours,
    super.price3Hours,
    super.priceUntilBus,
    super.amenities,
    super.images,
    required super.status,
    required super.isOperational,
    super.averageRating,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Helper to extract value from Go-style nullable types like {String: "value", Valid: true}
  /// or return the value directly if it's already a plain type
  static T? _extractNullable<T>(dynamic value) {
    if (value == null) return null;

    // If it's already the target type, return it directly
    if (value is T) return value;

    // Handle Go's sql.NullString format: {String: "value", Valid: true}
    if (value is Map<String, dynamic>) {
      final valid = value['Valid'] as bool? ?? false;
      if (!valid) return null;

      // Try different key names based on type
      if (T == String) {
        return value['String'] as T?;
      } else if (T == int) {
        final intVal = value['Int64'] ?? value['Int32'];
        if (intVal != null) return intVal as T?;
      } else if (T == double) {
        return value['Float64'] as T?;
      }
    }

    // Try to convert string to the target type
    if (T == String && value != null) {
      return value.toString() as T;
    }

    return null;
  }

  /// Helper to extract string and convert numbers to string if needed
  static String? _extractString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;

    if (value is Map<String, dynamic>) {
      final valid = value['Valid'] as bool? ?? false;
      if (!valid) return null;
      final strVal = value['String'];
      if (strVal != null) return strVal.toString();
    }

    return value.toString();
  }

  /// Helper to extract int from various formats
  static int? _extractInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;

    if (value is Map<String, dynamic>) {
      final valid = value['Valid'] as bool? ?? false;
      if (!valid) return null;
      final intVal = value['Int64'] ?? value['Int32'];
      if (intVal != null) return intVal as int;
    }

    if (value is String) {
      return int.tryParse(value);
    }

    return null;
  }

  factory LoungeModel.fromJson(Map<String, dynamic> json) {
    // Handle created_at - could be string or missing
    DateTime createdAt;
    if (json['created_at'] != null) {
      createdAt = DateTime.parse(json['created_at'] as String);
    } else {
      createdAt = DateTime.now();
    }

    // Handle updated_at - could be string or missing
    DateTime updatedAt;
    if (json['updated_at'] != null) {
      updatedAt = DateTime.parse(json['updated_at'] as String);
    } else {
      updatedAt = createdAt;
    }

    return LoungeModel(
      id: json['id'] as String,
      loungeOwnerId: json['lounge_owner_id'] as String? ?? '',
      loungeName: json['lounge_name'] as String,
      description: _extractString(json['description']),
      address: _extractString(json['address']) ?? '',
      state: _extractString(json['state']),
      country: _extractString(json['country']),
      postalCode: _extractString(json['postal_code']),
      latitude: _extractString(json['latitude']),
      longitude: _extractString(json['longitude']),
      contactPhone: _extractString(json['contact_phone']),
      capacity: _extractInt(json['capacity']),
      routes: (json['routes'] as List<dynamic>?)
          ?.map((r) => LoungeRouteModel.fromJson(r as Map<String, dynamic>))
          .toList(),
      price1Hour: _extractString(json['price_1_hour']),
      price2Hours: _extractString(json['price_2_hours']),
      price3Hours: _extractString(json['price_3_hours']),
      priceUntilBus: _extractString(json['price_until_bus']),
      amenities: (json['amenities'] as List<dynamic>?)
          ?.map((a) => a as String)
          .toList(),
      images: (json['images'] as List<dynamic>?)
          ?.map((i) => i as String)
          .toList(),
      status: json['status'] as String? ?? 'pending',
      isOperational: json['is_operational'] as bool? ?? true,
      averageRating: _extractString(json['average_rating']),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lounge_name': loungeName,
      'description': description,
      'address': address,
      'contact_phone': contactPhone,
      'latitude': latitude,
      'longitude': longitude,
      'capacity': capacity,
      'routes': routes
          ?.map((r) => LoungeRouteModel.fromEntity(r).toJson())
          .toList(),
      'price_1_hour': price1Hour,
      'price_2_hours': price2Hours,
      'price_3_hours': price3Hours,
      'price_until_bus': priceUntilBus,
      'amenities': amenities,
      'images': images,
    };
  }
}

