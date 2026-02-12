import '../../domain/entities/driver.dart';

/// Data Model: Driver
/// Handles JSON serialization/deserialization for driver API communication
class DriverModel extends Driver {
  const DriverModel({
    required super.id,
    required super.loungeId,
    required super.fullName,
    required super.nicNumber,
    required super.contactNumber,
    required super.vehicleNumber,
    required super.vehicleType,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Create model from JSON (from API response)
  factory DriverModel.fromJson(Map<String, dynamic> json) {
    return DriverModel(
      id: json['id'] as String,
      loungeId: json['lounge_id'] as String,
      fullName: json['name'] as String,
      nicNumber: json['nic_number'] as String,
      contactNumber: json['contact_no'] as String,
      vehicleNumber: json['vehicle_no'] as String,
      vehicleType: json['vehicle_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert model to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'lounge_id': loungeId,
      'name': fullName,
      'nic_number': nicNumber,
      'contact_no': contactNumber,
      'vehicle_no': vehicleNumber,
      'vehicle_type': vehicleType,
    };
  }

  /// Convert from domain entity
  factory DriverModel.fromEntity(Driver entity) {
    return DriverModel(
      id: entity.id,
      loungeId: entity.loungeId,
      fullName: entity.fullName,
      nicNumber: entity.nicNumber,
      contactNumber: entity.contactNumber,
      vehicleNumber: entity.vehicleNumber,
      vehicleType: entity.vehicleType,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
