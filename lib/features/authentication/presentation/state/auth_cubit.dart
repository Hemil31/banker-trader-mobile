import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/exceptions/auth_exception.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
  }) : _login = loginUseCase,
       _logout = logoutUseCase,
       _me = getCurrentUserUseCase,
       _changePassword = changePasswordUseCase,
       super(const AuthInitial());

  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _me;
  final ChangePasswordUseCase _changePassword;

  Future<void> login(String identifier, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _login(identifier, password);
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message, e.fieldErrors));
    } catch (_) {
      emit(const AuthError(
        'Unable to reach the server. Check your connection and try again.',
      ));
    }
  }

  Future<void> restoreSession() async {
    emit(const AuthLoading());
    try {
      final user = await _me();
      emit(AuthAuthenticated(user));
    } catch (_) {
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> logout() async {
    await _logout();
    emit(const AuthUnauthenticated());
  }

  /// Changes the current password. Throws the original error on failure so the
  /// caller can surface the backend message.
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }
}
