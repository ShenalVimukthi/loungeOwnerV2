import 'package:dartz/dartz.dart';
import '../entities/lounge.dart';
import '../entities/lounge_route.dart';
import '../../core/error/failures.dart';

abstract class LoungeRepository {
  /// Add a new lounge (Step 3)
  Future<Either<Failure, String>> addLounge({
    required String loungeName,
    required String address,
    String? state,
    String? postalCode,
    String? district,
    required String latitude,
    required String longitude,
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
  });

  /// Get all lounges for current owner
  Future<Either<Failure, List<Lounge>>> getMyLounges();

  /// Get all registered lounges (for staff member selection)
  Future<Either<Failure, List<Lounge>>> getAllLounges();

  /// Get lounge by ID
  Future<Either<Failure, Lounge>> getLoungeById(String id);

  /// Update lounge
  Future<Either<Failure, void>> updateLounge(Lounge lounge);

  /// Delete lounge
  Future<Either<Failure, void>> deleteLounge(String id);
}
