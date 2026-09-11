import '../repositories/authentication_repository.dart';

class ChangePasswordUseCase {
  ChangePasswordUseCase({required AuthenticationRepository repository})
    : _repository = repository;

  final AuthenticationRepository _repository;

  Future<void> call({
    required String currentPassword,
    required String newPassword,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}