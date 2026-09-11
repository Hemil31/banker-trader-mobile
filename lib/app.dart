import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/authentication/presentation/state/auth_cubit.dart';
import 'features/authentication/presentation/state/auth_state.dart';
import 'features/broker/presentation/state/broker_cubit.dart';
import 'features/news/presentation/state/news_cubit.dart';
import 'features/trading/presentation/pages/trading_home_page.dart';
import 'features/trading/presentation/state/trading_cubit.dart';

class BankerTraderApp extends StatelessWidget {
  const BankerTraderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthCubit>(
          create: (_) => locator<AuthCubit>()..restoreSession(),
        ),
        BlocProvider<TradingCubit>(create: (_) => locator<TradingCubit>()),
        BlocProvider<BrokerCubit>(create: (_) => locator<BrokerCubit>()),
        BlocProvider<NewsCubit>(create: (_) => locator<NewsCubit>()),
      ],
      child: MaterialApp(
        title: 'BankerTrader',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0D1B2A)),
          useMaterial3: true,
        ),
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        return switch (state) {
          AuthInitial() || AuthLoading() => const _SplashPlaceholder(),
          AuthAuthenticated() => const TradingHomePage(),
          AuthError() || AuthUnauthenticated() => const LoginPage(),
        };
      },
    );
  }
}

class _SplashPlaceholder extends StatelessWidget {
  const _SplashPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}
