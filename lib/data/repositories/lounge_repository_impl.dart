import 'package:dartz/dartz.dart';
import '../../domain/entities/lounge.dart';
import '../../domain/entities/lounge_route.dart';
import '../../domain/repositories/lounge_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../datasources/lounge_remote_datasource.dart';
import '../models/lounge_model.dart';
import '../models/lounge_route_model.dart';

/// Implementation of LoungeRepository
/// Converts data source calls to Either<Failure, T> pattern
/// Handles exception to failure conversion
class LoungeRepositoryImpl implements LoungeRepository {
  final LoungeRemoteDataSource remoteDataSource;

  LoungeRepositoryImpl({required this.remoteDataSource});

  @override
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
  }) async {
    try {
      // Convert latitude/longitude to double
      final lat = double.parse(latitude);
      final lng = double.parse(longitude);

      final response = await remoteDataSource.addLounge(
        loungeName: loungeName,
        address: address,
        city: '', // Not required by backend anymore
        state: state ?? '',
        postalCode: postalCode ?? '',
        district: district,
        latitude: lat,
        longitude: lng,
        contactPersonName: '', // Not used
        businessEmail: '', // Not used
        businessPhone: contactPhone,
        description: description ?? '',
        loungePhotos: images,
        facilities: amenities,
        operatingHours: {}, // Not used
        capacity: capacity,
        price1Hour: price1Hour,
        price2Hours: price2Hours,
        price3Hours: price3Hours,
        priceUntilBus: priceUntilBus,
        routes: routes.map((r) => LoungeRouteModel.fromEntity(r)).toList(),
      );

      print('📍 Repository - Response received: $response');

      // Extract lounge_id from response
      final loungeId = response['lounge_id'] as String?;
      if (loungeId == null || loungeId.isEmpty) {
        print('❌ Repository - No lounge_id in response');
        return Left(ServerFailure('Server did not return a valid lounge ID'));
      }

      print('✅ Repository - Lounge created successfully with ID: $loungeId');
      return Right(loungeId);
    } on ServerException catch (e) {
      print('❌ Repository - ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ Repository - Unexpected error: ${e.toString()}');
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Lounge>>> getMyLounges() async {
    try {
      print('📍 Repository - Calling getMyLounges...');
      final jsonList = await remoteDataSource.getMyLounges();
      print('📍 Repository - Got ${jsonList.length} lounges from API');

      final lounges = <Lounge>[];
      for (var json in jsonList) {
        try {
          print(
            '📍 Parsing lounge: ${json['lounge_name']} (${json['status']})',
          );
          lounges.add(LoungeModel.fromJson(json));
        } catch (e) {
          print('⚠️ Failed to parse lounge: $e');
          print('   JSON: $json');
        }
      }

      print('✅ Repository - Successfully parsed ${lounges.length} lounges');
      return Right(lounges);
    } on ServerException catch (e) {
      print('❌ Repository - ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ Repository - Unexpected error: ${e.toString()}');
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, List<Lounge>>> getAllLounges() async {
    try {
      print('📍 Repository - Calling getAllLounges...');
      final jsonList = await remoteDataSource.getAllLounges();
      print('📍 Repository - Got ${jsonList.length} lounges from API');

      final lounges = <Lounge>[];
      for (var json in jsonList) {
        try {
          print('📍 Parsing lounge: ${json['lounge_name']}');
          lounges.add(LoungeModel.fromJson(json));
        } catch (e) {
          print('⚠️ Failed to parse lounge: $e');
          print('   JSON: $json');
        }
      }

      print('✅ Repository - Successfully parsed ${lounges.length} lounges');
      return Right(lounges);
    } on ServerException catch (e) {
      print('❌ Repository - ServerException: ${e.message}');
      return Left(ServerFailure(e.message));
    } catch (e) {
      print('❌ Repository - Unexpected error: ${e.toString()}');
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, Lounge>> getLoungeById(String id) async {
    try {
      final json = await remoteDataSource.getLoungeById(id);
      final lounge = LoungeModel.fromJson(json);
      return Right(lounge);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> updateLounge(Lounge lounge) async {
    try {
      // TODO: Implement update when backend endpoint is ready
      // Will need to convert Lounge entity to backend format similar to addLounge
      return Left(ServerFailure('Update lounge not implemented yet'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteLounge(String id) async {
    try {
      // TODO: Implement delete when backend endpoint is ready
      return Left(ServerFailure('Delete lounge not implemented yet'));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: ${e.toString()}'));
    }
  }
}
