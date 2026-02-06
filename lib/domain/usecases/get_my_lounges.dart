import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../entities/lounge.dart';
import '../repositories/lounge_repository.dart';

class GetMyLounges {
  final LoungeRepository repository;

  GetMyLounges(this.repository);

  Future<Either<Failure, List<Lounge>>> call() async {
    return await repository.getMyLounges();
  }
}
