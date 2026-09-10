import '../repositories/authentication_repository.dart';

class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthenticationRepository _repository;

  Future<void> call() => _repository.logout();
}
