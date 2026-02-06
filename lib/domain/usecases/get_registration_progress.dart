import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/registration_progress.dart';
import '../repositories/lounge_owner_repository.dart';

class GetRegistrationProgress {
  final LoungeOwnerRepository repository;

  GetRegistrationProgress(this.repository);

  Future<Either<Failure, RegistrationProgress>> call() async {
    return await repository.getRegistrationProgress();
  }
}
