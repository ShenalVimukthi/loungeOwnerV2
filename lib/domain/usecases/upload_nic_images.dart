import 'package:dartz/dartz.dart';
import '../../core/error/failures.dart';
import '../repositories/lounge_owner_repository.dart';

class UploadNICImages {
  final LoungeOwnerRepository repository;

  UploadNICImages(this.repository);

  Future<Either<Failure, bool>> call({
    required String frontImagePath,
    required String backImagePath,
  }) async {
    if (frontImagePath.trim().isEmpty) {
      return Left(ValidationFailure('Manager NIC front image is required'));
    }

    if (backImagePath.trim().isEmpty) {
      return Left(ValidationFailure('Manager NIC back image is required'));
    }

    return await repository.uploadManagerNIC(
      managerNicFrontUrl: frontImagePath.trim(),
      managerNicBackUrl: backImagePath.trim(),
      managerNicNumber: '',
      ocrExtracted: '',
      ocrMatched: false,
    );
  }
}
