import '../../domain/entities/user.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../core/error/failures.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../datasources/auth_remote_datasource.dart';
import '../datasources/auth_local_datasource.dart';
import '../models/user_model.dart';

/// Implementation of AuthRepository
/// Coordinates between remote and local data sources
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final ApiClient apiClient;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.apiClient,
  });

  @override
  Future<Either<Failure, void>> sendOtp(String phoneNumber) async {
    try {
      await remoteDataSource.sendOtp(phoneNumber);
      return Either.right(null);
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Either.left(NetworkFailure(e.message, e.code));
    } on AppException catch (e) {
      return Either.left(UnknownFailure(e.message, e.code));
    } catch (e) {
      return Either.left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthResult>> verifyOtp({
    required String phoneNumber,
    required String otp,
  }) async {
    try {
      // Call remote API
      final remoteResult = await remoteDataSource.verifyOtp(phoneNumber, otp);

      // Save tokens to local storage
      await localDataSource.saveTokens(remoteResult.tokens);

      // Save user to local storage
      await localDataSource.saveUser(remoteResult.user);

      // Convert to domain entities
      return Either.right(
        AuthResult(
          user: remoteResult.user.toEntity(),
          tokens: remoteResult.tokens.toEntity(),
          roles: remoteResult.roles,
          isNewUser: remoteResult.isNewUser,
          registrationStep: remoteResult.registrationStep,
        ),
      );
    } on AuthException catch (e) {
      return Either.left(AuthFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Either.left(NetworkFailure(e.message, e.code));
    } on CacheException catch (e) {
      return Either.left(CacheFailure(e.message, e.code));
    } on AppException catch (e) {
      return Either.left(UnknownFailure(e.message, e.code));
    } catch (e) {
      return Either.left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AuthTokens>> refreshToken() async {
    try {
      // Get current tokens from local storage
      final currentTokens = await localDataSource.getTokens();
      if (currentTokens == null) {
        return Either.left(const AuthFailure('No refresh token available'));
      }

      // Call remote API to refresh
      final newTokens = await remoteDataSource.refreshToken(
        currentTokens.refreshToken,
      );

      // Save new tokens
      await localDataSource.saveTokens(newTokens);

      return Either.right(newTokens.toEntity());
    } on AuthException catch (e) {
      return Either.left(AuthFailure(e.message, e.code));
    } on ServerException catch (e) {
      return Either.left(ServerFailure(e.message, e.code));
    } on NetworkException catch (e) {
      return Either.left(NetworkFailure(e.message, e.code));
    } on CacheException catch (e) {
      return Either.left(CacheFailure(e.message, e.code));
    } on AppException catch (e) {
      return Either.left(UnknownFailure(e.message, e.code));
    } catch (e) {
      return Either.left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout({bool logoutAll = false}) async {
    try {
      // Get current tokens
      final tokens = await localDataSource.getTokens();

      // Call remote API (best effort - don't fail if it fails)
      await remoteDataSource.logout(
        refreshToken: tokens?.refreshToken,
        logoutAll: logoutAll,
      );

      // Clear local storage (always do this, even if API fails)
      await localDataSource.clearAll();

      // Clear cached tokens in ApiClient
      apiClient.clearCachedTokens();

      return Either.right(null);
    } on CacheException catch (e) {
      return Either.left(CacheFailure(e.message, e.code));
    } catch (e) {
      // Even if there's an error, try to clear local storage
      try {
        await localDataSource.clearAll();
        apiClient.clearCachedTokens();
      } catch (_) {}
      return Either.left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      return await localDataSource.hasValidTokens();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userModel = await localDataSource.getUser();
      return userModel?.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<Either<Failure, User>> updateUserProfile(User user) async {
    try {
      // Convert to model and save to local storage
      final userModel = UserModel.fromEntity(user);
      await localDataSource.saveUser(userModel);
      return Either.right(user);
    } on CacheException catch (e) {
      return Either.left(CacheFailure(e.message, e.code));
    } catch (e) {
      return Either.left(UnknownFailure(e.toString()));
    }
  }
}
