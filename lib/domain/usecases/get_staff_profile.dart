import '../repositories/staff_repository.dart';
import '../../core/error/failures.dart';
import '../repositories/auth_repository.dart'; // For Either

/// Use Case: Get Staff Profile
///
/// Business Rules:
/// - User must be authenticated
/// - Fetches complete profile (user + staff + bus owner)
class GetStaffProfileUseCase {
  final StaffRepository repository;

  GetStaffProfileUseCase(this.repository);

  /// Execute the use case
  Future<Either<Failure, StaffProfile>> call() async {
    // Delegate to repository
    return await repository.getStaffProfile();
  }
}
