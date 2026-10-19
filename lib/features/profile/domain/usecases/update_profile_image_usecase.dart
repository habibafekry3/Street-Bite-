import '../repositories/profile_repository.dart';

class UpdateProfileImageUseCase {
  final ProfileRepository _repository;

  UpdateProfileImageUseCase(this._repository);

  Future<void> call(String imageBase64) {
    return _repository.updateProfileImage(imageBase64);
  }
}
