import '../../domain/entities/lounge_booking.dart';

/// Data Model: Lounge Booking
/// Handles JSON serialization/deserialization for API communication
class LoungeBookingModel extends LoungeBooking {
  const LoungeBookingModel({
    required super.id,
    required super.loungeId,
    required super.passengerId,
    required super.bookingReference,
    required super.checkInTime,
    super.checkOutTime,
    required super.durationHours,
    required super.guestCount,
    required super.status,
    required super.amountPaid,
    super.paymentMethod,
    super.specialRequests,
    required super.createdAt,
    required super.updatedAt,
    super.loungeName,
    super.loungeAddress,
    super.passengerName,
    super.passengerPhone,
  });

  /// Create model from JSON (from API response)
  factory LoungeBookingModel.fromJson(Map<String, dynamic> json) {
    return LoungeBookingModel(
      id: json['id'] as String,
      loungeId: json['lounge_id'] as String,
      passengerId: json['passenger_id'] as String,
      bookingReference: json['booking_reference'] as String,
      checkInTime: DateTime.parse(json['check_in_time'] as String),
      checkOutTime: json['check_out_time'] != null
          ? DateTime.parse(json['check_out_time'] as String)
          : null,
      durationHours: json['duration_hours'] as int? ?? 1,
      guestCount: json['guest_count'] as int? ?? 1,
      status: json['status'] as String? ?? 'pending',
      amountPaid: json['amount_paid'] as String? ?? '0.00',
      paymentMethod: json['payment_method'] as String?,
      specialRequests: json['special_requests'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      loungeName: json['lounge_name'] as String?,
      loungeAddress: json['lounge_address'] as String?,
      passengerName: json['passenger_name'] as String?,
      passengerPhone: json['passenger_phone'] as String?,
    );
  }

  /// Convert model to JSON (for API requests)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'lounge_id': loungeId,
      'passenger_id': passengerId,
      'booking_reference': bookingReference,
      'check_in_time': checkInTime.toIso8601String(),
      if (checkOutTime != null)
        'check_out_time': checkOutTime!.toIso8601String(),
      'duration_hours': durationHours,
      'guest_count': guestCount,
      'status': status,
      'amount_paid': amountPaid,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (specialRequests != null) 'special_requests': specialRequests,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      if (loungeName != null) 'lounge_name': loungeName,
      if (loungeAddress != null) 'lounge_address': loungeAddress,
      if (passengerName != null) 'passenger_name': passengerName,
      if (passengerPhone != null) 'passenger_phone': passengerPhone,
    };
  }

  /// Convert from domain entity
  factory LoungeBookingModel.fromEntity(LoungeBooking entity) {
    return LoungeBookingModel(
      id: entity.id,
      loungeId: entity.loungeId,
      passengerId: entity.passengerId,
      bookingReference: entity.bookingReference,
      checkInTime: entity.checkInTime,
      checkOutTime: entity.checkOutTime,
      durationHours: entity.durationHours,
      guestCount: entity.guestCount,
      status: entity.status,
      amountPaid: entity.amountPaid,
      paymentMethod: entity.paymentMethod,
      specialRequests: entity.specialRequests,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      loungeName: entity.loungeName,
      loungeAddress: entity.loungeAddress,
      passengerName: entity.passengerName,
      passengerPhone: entity.passengerPhone,
    );
  }
}
