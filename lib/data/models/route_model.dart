/// Models for master routes and stops
class MasterRouteStop {
  final String id;
  final String masterRouteId;
  final String stopName;
  final int stopOrder;
  final int? arrivalTimeOffsetMinutes;
  final double? latitude;
  final double? longitude;
  final bool isMajorStop;

  MasterRouteStop({
    required this.id,
    required this.masterRouteId,
    required this.stopName,
    required this.stopOrder,
    this.arrivalTimeOffsetMinutes,
    this.latitude,
    this.longitude,
    this.isMajorStop = false,
  });

  factory MasterRouteStop.fromJson(Map<String, dynamic> json) {
    return MasterRouteStop(
      id: json['id'],
      masterRouteId: json['master_route_id'],
      stopName: json['stop_name'],
      stopOrder: json['stop_order'],
      arrivalTimeOffsetMinutes: json['arrival_time_offset_minutes'],
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
      isMajorStop: json['is_major_stop'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'master_route_id': masterRouteId,
      'stop_name': stopName,
      'stop_order': stopOrder,
      'arrival_time_offset_minutes': arrivalTimeOffsetMinutes,
      'latitude': latitude,
      'longitude': longitude,
      'is_major_stop': isMajorStop,
    };
  }
}

class MasterRoute {
  final String id;
  final String routeNumber;
  final String routeName;
  final String originCity;
  final String destinationCity;
  final double? totalDistanceKm;
  final int? estimatedDurationMinutes;
  final bool isActive;
  final List<MasterRouteStop> stops;

  MasterRoute({
    required this.id,
    required this.routeNumber,
    required this.routeName,
    required this.originCity,
    required this.destinationCity,
    this.totalDistanceKm,
    this.estimatedDurationMinutes,
    this.isActive = true,
    this.stops = const [],
  });

  String get routeDisplay => '$originCity - $destinationCity';

  factory MasterRoute.fromJson(Map<String, dynamic> json) {
    return MasterRoute(
      id: json['id'],
      routeNumber: json['route_number'],
      routeName: json['route_name'],
      originCity: json['origin_city'],
      destinationCity: json['destination_city'],
      totalDistanceKm: json['total_distance_km']?.toDouble(),
      estimatedDurationMinutes: json['estimated_duration_minutes'],
      isActive: json['is_active'] ?? true,
      stops: (json['stops'] as List?)
              ?.map((e) => MasterRouteStop.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'route_number': routeNumber,
      'route_name': routeName,
      'origin_city': originCity,
      'destination_city': destinationCity,
      'total_distance_km': totalDistanceKm,
      'estimated_duration_minutes': estimatedDurationMinutes,
      'is_active': isActive,
      'stops': stops.map((e) => e.toJson()).toList(),
    };
  }
}
