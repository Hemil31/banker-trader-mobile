import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthenticationRepository _repository;

  Future<User> call(String identifier, String password) async {
    return (await _repository.login(identifier, password)).$1;
  }
}
