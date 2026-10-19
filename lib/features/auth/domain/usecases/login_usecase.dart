import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository _repository;
  const LoginUseCase(this._repository);

  Future<UserEntity> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}
