import '../entities/user.dart';
import '../repositories/authentication_repository.dart';

class GetCurrentUserUseCase {
  const GetCurrentUserUseCase(this._repository);

  final AuthenticationRepository _repository;

  Future<User> call() => _repository.me();
}
