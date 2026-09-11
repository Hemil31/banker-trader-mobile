import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:banker_trader/features/authentication/domain/entities/auth_tokens.dart';
import 'package:banker_trader/features/authentication/domain/entities/user.dart';
import 'package:banker_trader/features/authentication/domain/repositories/authentication_repository.dart';
import 'package:banker_trader/features/authentication/domain/usecases/change_password_usecase.dart';
import 'package:banker_trader/features/authentication/domain/usecases/get_current_user_usecase.dart';
import 'package:banker_trader/features/authentication/domain/usecases/login_usecase.dart';
import 'package:banker_trader/features/authentication/domain/usecases/logout_usecase.dart';
import 'package:banker_trader/features/authentication/presentation/pages/login_page.dart';
import 'package:banker_trader/features/authentication/presentation/state/auth_cubit.dart';
import 'package:banker_trader/features/authentication/presentation/state/auth_state.dart';

class _FakeRepository implements AuthenticationRepository {
  @override
  Future<(User, AuthTokens)> login(String identifier, String password) async {
    return (
      User(
        id: '1',
        name: 'Tester',
        email: identifier,
        username: identifier,
      ),
      const AuthTokens(accessToken: 'a', refreshToken: 'r'),
    );
  }

  @override
  Future<AuthTokens> refresh(String refreshToken) async {
    return const AuthTokens(accessToken: 'a', refreshToken: 'r');
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {}

  @override
  Future<User> me() async => const User(
    id: '1',
    name: 'Tester',
    email: 't@example.com',
    username: 'tester',
  );
}

AuthCubit _buildCubit() {
  final repo = _FakeRepository();
  return AuthCubit(
    loginUseCase: LoginUseCase(repo),
    logoutUseCase: LogoutUseCase(repo),
    getCurrentUserUseCase: GetCurrentUserUseCase(repo),
    changePasswordUseCase: ChangePasswordUseCase(repository: repo),
  );
}

void main() {
  testWidgets('LoginPage renders identifier and password fields', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider<AuthCubit>(
        create: (_) => _buildCubit(),
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    expect(find.text('BankerTrader'), findsOneWidget);
    expect(find.text('Email or username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Sign in'), findsOneWidget);
  });

  testWidgets('Login tips into authenticated state on submit', (tester) async {
    final cubit = _buildCubit();
    await tester.pumpWidget(
      BlocProvider<AuthCubit>(
        create: (_) => cubit,
        child: const MaterialApp(home: LoginPage()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'tester');
    await tester.enterText(find.byType(TextFormField).at(1), 'secret');
    await tester.tap(find.widgetWithText(FilledButton, 'Sign in'));
    await tester.pumpAndSettle();

    expect(cubit.state, isA<AuthAuthenticated>());
  });
}
