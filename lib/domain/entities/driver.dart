/// Domain Entity: Driver
/// Represents a driver working for a lounge
class Driver {
  final String id;
  final String loungeId;
  final String fullName;
  final String nicNumber;
  final String contactNumber;
  final String vehicleNumber;
  final String vehicleType; // three_wheeler, car, van
  final DateTime createdAt;
  final DateTime updatedAt;

  const Driver({
    required this.id,
    required this.loungeId,
    required this.fullName,
    required this.nicNumber,
    required this.contactNumber,
    required this.vehicleNumber,
    required this.vehicleType,
    required this.createdAt,
    required this.updatedAt,
  });

  // Helper getters
  bool get isThreeWheeler => vehicleType == 'three_wheeler';
  bool get isCar => vehicleType == 'car';
  bool get isVan => vehicleType == 'van';
}
