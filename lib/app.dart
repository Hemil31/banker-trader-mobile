import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/injection.dart';
import 'core/theme/app_theme.dart';
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
        theme: buildAppTheme(),
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Size-check first, then draw the splash animation: scale the
            // 16:9 GIF to fill ~86% of the available width while keeping its
            // aspect ratio, so it covers every screen size consistently.
            final imageWidth = (constraints.maxWidth * 0.86).clamp(280.0, 460.0);
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/splash.gif',
                    width: imageWidth,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => Icon(
                      Icons.trending_up_rounded,
                      color: AppColors.accent,
                      size: 48,
                    ),
                  ),
                  const SizedBox(height: AppSpace.xxl),
                  const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.accent,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
