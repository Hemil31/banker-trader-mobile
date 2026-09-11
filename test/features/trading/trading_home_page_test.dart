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
import 'package:banker_trader/features/authentication/presentation/state/auth_cubit.dart';
import 'package:banker_trader/features/authentication/presentation/state/auth_state.dart';
import 'package:banker_trader/features/broker/domain/entities/broker.dart';
import 'package:banker_trader/features/broker/domain/entities/broker_account.dart';
import 'package:banker_trader/features/broker/domain/entities/broker_authorization.dart';
import 'package:banker_trader/features/broker/domain/repositories/broker_repository.dart';
import 'package:banker_trader/features/broker/domain/usecases/disconnect_broker_usecase.dart';
import 'package:banker_trader/features/broker/domain/usecases/fetch_broker_accounts_usecase.dart';
import 'package:banker_trader/features/broker/domain/usecases/fetch_brokers_usecase.dart';
import 'package:banker_trader/features/broker/domain/usecases/open_broker_authorization_usecase.dart';
import 'package:banker_trader/features/broker/presentation/state/broker_cubit.dart';
import 'package:banker_trader/features/broker/presentation/state/broker_state.dart';
import 'package:banker_trader/features/trading/domain/entities/account.dart';
import 'package:banker_trader/features/trading/domain/entities/config_row.dart';
import 'package:banker_trader/features/trading/domain/entities/portfolio_overview.dart';
import 'package:banker_trader/features/trading/domain/entities/portfolio_summary.dart';
import 'package:banker_trader/features/trading/domain/repositories/trading_repository.dart';
import 'package:banker_trader/features/trading/domain/usecases/fetch_config_usecase.dart';
import 'package:banker_trader/features/trading/domain/usecases/fetch_portfolio_usecase.dart';
import 'package:banker_trader/features/trading/domain/usecases/run_paper_session_usecase.dart';
import 'package:banker_trader/features/trading/presentation/pages/trading_home_page.dart';
import 'package:banker_trader/features/trading/presentation/state/trading_cubit.dart';

class _FakeAuthRepository implements AuthenticationRepository {
  @override
  Future<(User, AuthTokens)> login(String identifier, String password) async {
    return (
      User(id: '1', name: 'Tester', email: 't@example.com', username: 'tester'),
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

class _FakeBrokerRepository implements BrokerRepository {
  @override
  Future<List<Broker>> fetchBrokers() async => const [
    Broker(slug: 'upstox', name: 'Upstox', paper: false, active: true),
    Broker(slug: 'zerodha', name: 'Zerodha', paper: false, active: false),
  ];

  @override
  Future<List<BrokerAccount>> fetchAccounts() async => const [
    BrokerAccount(
      id: 'acct-1',
      name: 'Default',
      mode: 'paper',
      connected: false,
    ),
    BrokerAccount(
      id: 'acct-2',
      name: 'Live',
      mode: 'live',
      connected: true,
      broker: ConnectableBrokerDetail(slug: 'upstox', name: 'Upstox'),
    ),
  ];

  @override
  Future<BrokerAccount> fetchStatus(String tradingAccountId) async =>
      const BrokerAccount(
        id: 'acct-2',
        name: 'Live',
        mode: 'live',
        connected: true,
        broker: ConnectableBrokerDetail(slug: 'upstox', name: 'Upstox'),
      );

  @override
  Future<BrokerAuthorization> getAuthorization(
    String tradingAccountId,
    String slug,
  ) async => const BrokerAuthorization(
    authorizationUrl: 'https://example.com/oauth',
  );

  @override
  Future<void> disconnect(String tradingAccountId) async {}

  @override
  Future<String> authorizeFeed(String tradingAccountId, String type) async =>
      'wss://example.com/feed';
}

class _FakeTradingRepository implements TradingRepository {
  @override
  Future<PortfolioOverview> fetchPortfolio() async => PortfolioOverview(
    account: const Account(
      id: 1,
      name: 'Paper Trading',
      mode: 'paper',
      startingCapital: 100000,
      availableCash: 50000,
      investedAmount: 50000,
    ),
    portfolio: const PortfolioSummary(
      invested: 50000,
      unrealized: 1000,
      realized: 0,
      grossEquity: 101000,
      netEquity: 101000,
      openPositionsCount: 0,
    ),
    openPositions: const [],
    recentSignals: const [],
    recentPaperTrades: const [],
    marketBars: 0,
  );

  @override
  Future<List<ConfigRow>> fetchConfig() async => const [];

  @override
  Future<PaperRunResult> runPaperSession({List<int>? symbols}) async =>
      const PaperRunResult(
        signalsGenerated: 0,
        marketOk: true,
        entered: 0,
        blocked: 0,
        monitored: 0,
        exits: 0,
      );
}

Widget _buildApp() {
  final authRepo = _FakeAuthRepository();
  final brokerRepo = _FakeBrokerRepository();
  final tradingRepo = _FakeTradingRepository();

  final authCubit = AuthCubit(
    loginUseCase: LoginUseCase(authRepo),
    logoutUseCase: LogoutUseCase(authRepo),
    getCurrentUserUseCase: GetCurrentUserUseCase(authRepo),
    changePasswordUseCase: ChangePasswordUseCase(repository: authRepo),
  )..emit(
    AuthAuthenticated(
      const User(id: '1', name: 'Tester', email: 't@example.com', username: 'tester'),
    ),
  );

  final brokerCubit = BrokerCubit(
    fetchBrokers: FetchBrokersUseCase(repository: brokerRepo),
    fetchAccounts: FetchBrokerAccountsUseCase(repository: brokerRepo),
    openAuthorization: OpenBrokerAuthorizationUseCase(repository: brokerRepo),
    disconnectBroker: DisconnectBrokerUseCase(repository: brokerRepo),
  )..emit(
    BrokerLoaded(
      brokers: const [
        Broker(slug: 'upstox', name: 'Upstox', paper: false, active: true),
      ],
      accounts: const [
        BrokerAccount(
          id: 'acct-2',
          name: 'Live',
          mode: 'live',
          connected: true,
          broker: ConnectableBrokerDetail(slug: 'upstox', name: 'Upstox'),
        ),
      ],
    ),
  );

  final tradingCubit = TradingCubit(
    fetchPortfolio: FetchPortfolioUseCase(repository: tradingRepo),
    fetchConfig: FetchConfigUseCase(repository: tradingRepo),
    runPaperSession: RunPaperSessionUseCase(repository: tradingRepo),
  );

  return MultiBlocProvider(
    providers: [
      BlocProvider<AuthCubit>.value(value: authCubit),
      BlocProvider<BrokerCubit>.value(value: brokerCubit),
      BlocProvider<TradingCubit>.value(value: tradingCubit),
    ],
    child: const MaterialApp(home: TradingHomePage()),
  );
}

void main() {
  testWidgets('shell shows bottom navigation with five destinations', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Home'), findsWidgets);
    expect(find.text('Signals'), findsOneWidget);
    expect(find.text('Trades'), findsOneWidget);
    expect(find.text('Config'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Net equity'), findsOneWidget);
  });

  testWidgets('profile tab shows user info, accounts and broker credentials', (
    tester,
  ) async {
    await tester.pumpWidget(_buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();

    expect(find.text('Tester'), findsOneWidget);
    expect(find.text('t@example.com'), findsOneWidget);
    expect(find.text('Trading accounts'), findsOneWidget);
    expect(find.text('Broker credentials'), findsOneWidget);
    expect(find.text('Upstox'), findsWidgets);
    expect(find.text('Connected'), findsWidgets);

    await tester.drag(
      find.byType(ListView).hitTestable(),
      const Offset(0, -400),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign out'), findsOneWidget);
    expect(find.text('Change password'), findsOneWidget);
  });
}