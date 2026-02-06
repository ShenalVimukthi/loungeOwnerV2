import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/lounge_owner_repository.dart';

class CheckOCRBlock {
  final LoungeOwnerRepository repository;

  CheckOCRBlock(this.repository);

  Future<Either<Failure, DateTime?>> call() async {
    return await repository.checkOCRBlock();
  }
}
