import '../../domain/entities/staff.dart';
import '../../domain/repositories/staff_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../datasources/staff_remote_datasource.dart';
import '../../domain/repositories/auth_repository.dart'; // For Either

/// Implementation of StaffRepository
class StaffRepositoryImpl implements StaffRepository {
  final StaffRemoteDataSource remoteDataSource;

  StaffRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Staff>> registerStaff({
    required String userId,
    required String staffType,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    required int experienceYears,
    required String emergencyContact,
    required String emergencyContactName,
    String? busOwnerCode,
    String? busRegistrationNumber,
  }) async {
    try {
      final staffModel = await remoteDataSource.registerStaff(
        userId: userId,
        staffType: staffType,
        licenseNumber: licenseNumber,
        licenseExpiryDate: licenseExpiryDate,
        experienceYears: experienceYears,
        emergencyContact: emergencyContact,
        emergencyContactName: emergencyContactName,
        busOwnerCode: busOwnerCode,
        busRegistrationNumber: busRegistrationNumber,
      );

      return Either.right(staffModel.toEntity());
    } on ServerException catch (e) {
      return Either.left(StaffRegistrationFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Either.left(NetworkFailure(e.message, e.code));
    } on AuthException catch (e) {
      return Either.left(AuthFailure(e.message, e.code));
    } on AppException catch (e) {
      return Either.left(UnknownFailure(e.message, e.code));
    } catch (e) {
      return Either.left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, StaffProfile>> getStaffProfile() async {
    try {
      final result = await remoteDataSource.getStaffProfile();

      return Either.right(
        StaffProfile(
          user: result.user.toEntity(),
          staff: result.staff?.toEntity(),
          busOwner: result.busOwner,
        ),
      );
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Either.left(NetworkFailure(e.message, e.code));
    } on AuthException catch (e) {
      return Either.left(AuthFailure(e.message, e.code));
    } on AppException catch (e) {
      return Either.left(UnknownFailure(e.message, e.code));
    } catch (e) {
      return Either.left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Staff>> updateStaffProfile({
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    int? experienceYears,
    String? emergencyContact,
    String? emergencyContactName,
  }) async {
    try {
      final staffModel = await remoteDataSource.updateStaffProfile(
        licenseNumber: licenseNumber,
        licenseExpiryDate: licenseExpiryDate,
        experienceYears: experienceYears,
        emergencyContact: emergencyContact,
        emergencyContactName: emergencyContactName,
      );

      return Either.right(staffModel.toEntity());
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Either.left(NetworkFailure(e.message, e.code));
    } on AuthException catch (e) {
      return Either.left(AuthFailure(e.message, e.code));
    } on AppException catch (e) {
      return Either.left(UnknownFailure(e.message, e.code));
    } catch (e) {
      return Either.left(UnknownFailure(e.toString()));
    }
  }
}
