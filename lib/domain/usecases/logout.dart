import '../repositories/auth_repository.dart';
import '../../core/error/failures.dart';

/// Use Case: Logout
///
/// Business Rules:
/// - Can logout from current device only
/// - Can logout from all devices
class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  /// Execute the use case
  ///
  /// [logoutAll] - if true, logout from all devices
  Future<Either<Failure, void>> call({bool logoutAll = false}) async {
    return await repository.logout(logoutAll: logoutAll);
  }
}
