import '../repositories/profile_repository.dart';

class UpdateProfileNameUseCase {
  final ProfileRepository _repository;

  UpdateProfileNameUseCase(this._repository);

  Future<void> call(String name) {
    return _repository.updateProfileName(name);
  }
}
