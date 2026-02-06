import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/lounge_owner.dart';
import '../repositories/lounge_owner_repository.dart';

class GetProfile {
  final LoungeOwnerRepository repository;

  GetProfile(this.repository);

  Future<Either<Failure, LoungeOwner>> call() async {
    return await repository.getProfile();
  }
}
