import 'package:dartz/dartz.dart';
import '../entities/lounge.dart';
import '../repositories/lounge_repository.dart';
import '../../core/error/failures.dart';

class GetAllLounges {
  final LoungeRepository repository;

  GetAllLounges(this.repository);

  Future<Either<Failure, List<Lounge>>> call() async {
    return await repository.getAllLounges();
  }
}
