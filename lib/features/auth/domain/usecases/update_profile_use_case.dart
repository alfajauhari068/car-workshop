import 'package:dartz/dartz.dart';
import '../../../../core/errors/failure.dart';
import '../../../../core/usecase/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/user_repository.dart';

class UpdateProfileUseCase implements UseCase<UserEntity, UpdateProfileParams> {
  final UserRepository repository;

  UpdateProfileUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateProfileParams params) {
    return repository.updateUserProfile(
      params.uid,
      params.skills,
      params.yearsOfExperience,
    );
  }
}

class UpdateProfileParams {
  final String uid;
  final List<String>? skills;
  final String? yearsOfExperience;

  UpdateProfileParams({
    required this.uid,
    this.skills,
    this.yearsOfExperience,
  });
}
