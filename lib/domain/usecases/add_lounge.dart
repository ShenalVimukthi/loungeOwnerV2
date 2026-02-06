import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/lounge.dart';
import '../entities/lounge_route.dart';
import '../repositories/lounge_repository.dart';

class AddLounge {
  final LoungeRepository repository;

  AddLounge(this.repository);

  Future<Either<Failure, String>> call({
    required String loungeName,
    required String address,
    String? state,
    String? postalCode,
    String? district,
    required double latitude,
    required double longitude,
    required String contactPhone,
    required int capacity,
    required String price1Hour,
    required String price2Hours,
    required String price3Hours,
    required String priceUntilBus,
    required List<String> amenities,
    required List<String> images,
    String? description,
    required List<LoungeRoute> routes,
  }) async {
    // Validate required fields
    if (loungeName.trim().isEmpty) {
      return Left(ValidationFailure('Lounge name is required'));
    }

    if (address.trim().isEmpty) {
      return Left(ValidationFailure('Address is required'));
    }

    if (contactPhone.trim().isEmpty) {
      return Left(ValidationFailure('Contact phone is required'));
    }

    // Validate routes
    if (routes.isEmpty) {
      return Left(ValidationFailure('At least one route is required'));
    }
    
    // Validate each route has all required fields
    for (int i = 0; i < routes.length; i++) {
      final route = routes[i];
      if (route.masterRouteId.trim().isEmpty) {
        return Left(ValidationFailure('Route ${i + 1}: Route ID is required'));
      }
      if (route.stopBeforeId.trim().isEmpty) {
        return Left(ValidationFailure('Route ${i + 1}: Stop before is required'));
      }
      if (route.stopAfterId.trim().isEmpty) {
        return Left(ValidationFailure('Route ${i + 1}: Stop after is required'));
      }
    }

    // Validate phone format
    final phonePattern = RegExp(r'^\+?\d{10,15}$');
    if (!phonePattern.hasMatch(contactPhone.trim().replaceAll(' ', ''))) {
      return Left(ValidationFailure('Invalid phone number format'));
    }

    // Validate capacity
    if (capacity <= 0) {
      return Left(ValidationFailure('Capacity must be greater than 0'));
    }

    // Validate prices (basic format check)
    final pricePattern = RegExp(r'^\d+(\.\d{1,2})?$');
    if (!pricePattern.hasMatch(price1Hour)) {
      return Left(ValidationFailure('Invalid 1-hour price format'));
    }
    if (!pricePattern.hasMatch(price2Hours)) {
      return Left(ValidationFailure('Invalid 2-hour price format'));
    }
    if (!pricePattern.hasMatch(price3Hours)) {
      return Left(ValidationFailure('Invalid 3-hour price format'));
    }
    if (!pricePattern.hasMatch(priceUntilBus)) {
      return Left(ValidationFailure('Invalid until-bus price format'));
    }

    // Validate images
    if (images.isEmpty) {
      return Left(ValidationFailure('At least 1 image is required'));
    }
    if (images.length > 5) {
      return Left(ValidationFailure('Maximum 5 images allowed'));
    }

    // Validate amenities
    if (amenities.isEmpty) {
      return Left(ValidationFailure('At least 1 amenity is required'));
    }

    // Validate amenity codes (only allow standard codes)
    final invalidAmenities = amenities
        .where((a) => !LoungeAmenities.allCodes.contains(a))
        .toList();
    if (invalidAmenities.isNotEmpty) {
      return Left(ValidationFailure(
          'Invalid amenity codes: ${invalidAmenities.join(", ")}'));
    }

    print('📍 UseCase - Calling repository.addLounge...');
    final result = await repository.addLounge(
      loungeName: loungeName.trim(),
      address: address.trim(),
      state: state?.trim(),
      postalCode: postalCode?.trim(),
      district: district?.trim(),
      latitude: latitude.toString(),
      longitude: longitude.toString(),
      contactPhone: contactPhone.trim(),
      capacity: capacity,
      price1Hour: price1Hour.trim(),
      price2Hours: price2Hours.trim(),
      price3Hours: price3Hours.trim(),
      priceUntilBus: priceUntilBus.trim(),
      amenities: amenities,
      images: images,
      description: description?.trim(),
      routes: routes,
    );

    print('📍 UseCase - Result: ${result.isRight() ? "SUCCESS" : "FAILURE"}');
    return result;
  }
}
