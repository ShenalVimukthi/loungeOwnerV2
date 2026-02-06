class TransportLocation {
  final String id;
  final String loungeId;
  final String locationName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final Map<String, double>? prices; // vehicle_type -> price

  TransportLocation({
    required this.id,
    required this.loungeId,
    required this.locationName,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.prices,
  });
}
