import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required GetCurrentUserUseCase getCurrentUserUseCase,
  }) : _login = loginUseCase,
       _logout = logoutUseCase,
       _me = getCurrentUserUseCase,
       super(const AuthInitial());

  final LoginUseCase _login;
  final LogoutUseCase _logout;
  final GetCurrentUserUseCase _me;

  Future<void> login(String identifier, String password) async {
    emit(const AuthLoading());
    try {
      final user = await _login(identifier, password);
      emit(AuthAuthenticated(user));
    } catch (e) {
      emit(AuthError('Login failed. Please check your credentials.'));
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
}
