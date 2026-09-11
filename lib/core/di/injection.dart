import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

import '../config/app_config.dart';
import '../network/api_client.dart';
import '../storage/token_storage.dart';
import '../../features/authentication/data/repositories/authentication_repository_impl.dart';
import '../../features/authentication/data/sources/authentication_api.dart';
import '../../features/authentication/domain/repositories/authentication_repository.dart';
import '../../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../../features/authentication/domain/usecases/login_usecase.dart';
import '../../features/authentication/domain/usecases/logout_usecase.dart';
import '../../features/authentication/domain/usecases/change_password_usecase.dart';
import '../../features/authentication/presentation/state/auth_cubit.dart';
import '../../features/trading/data/repositories/trading_repository_impl.dart';
import '../../features/trading/data/sources/trading_api.dart';
import '../../features/trading/domain/repositories/trading_repository.dart';
import '../../features/trading/domain/usecases/fetch_config_usecase.dart';
import '../../features/trading/domain/usecases/fetch_portfolio_usecase.dart';
import '../../features/trading/domain/usecases/run_paper_session_usecase.dart';
import '../../features/trading/presentation/state/trading_cubit.dart';
import '../../features/broker/data/repositories/broker_repository_impl.dart';
import '../../features/broker/data/sources/broker_api.dart';
import '../../features/broker/domain/repositories/broker_repository.dart';
import '../../features/broker/domain/usecases/disconnect_broker_usecase.dart';
import '../../features/broker/domain/usecases/fetch_broker_accounts_usecase.dart';
import '../../features/broker/domain/usecases/fetch_brokers_usecase.dart';
import '../../features/broker/domain/usecases/open_broker_authorization_usecase.dart';
import '../../features/broker/presentation/state/broker_cubit.dart';

final GetIt locator = GetIt.instance;

void configureDependencies() {
  final baseUrl = AppConfig.apiBaseUrl;
  final dio = buildDio(baseUrl: baseUrl);
  final tokenStorage = TokenStorage();

  // Wire the auth interceptor into the shared Dio instance.
  dio.interceptors.add(
    AuthInterceptor(tokenStorage: tokenStorage, dio: dio, baseUrl: baseUrl),
  );

  final authenticationApi = AuthenticationApi(dio: dio, baseUrl: baseUrl);

  locator
    // Core
    ..registerSingleton<Dio>(dio)
    ..registerSingleton<TokenStorage>(tokenStorage)
    // Authentication
    ..registerSingleton<AuthenticationApi>(authenticationApi)
    ..registerLazySingleton<AuthenticationRepository>(
      () => AuthenticationRepositoryImpl(
        api: authenticationApi,
        tokenStorage: tokenStorage,
      ),
    )
    ..registerFactory(() => LoginUseCase(locator<AuthenticationRepository>()))
    ..registerFactory(() => LogoutUseCase(locator<AuthenticationRepository>()))
    ..registerFactory(
      () => GetCurrentUserUseCase(locator<AuthenticationRepository>()),
    )
    ..registerFactory(
      () => ChangePasswordUseCase(
        repository: locator<AuthenticationRepository>(),
      ),
    )
    ..registerFactory(
      () => AuthCubit(
        loginUseCase: locator<LoginUseCase>(),
        logoutUseCase: locator<LogoutUseCase>(),
        getCurrentUserUseCase: locator<GetCurrentUserUseCase>(),
        changePasswordUseCase: locator<ChangePasswordUseCase>(),
      ),
    );

  final tradingApi = TradingApi(dio: dio, baseUrl: baseUrl);

  locator
    // Trading
    ..registerSingleton<TradingApi>(tradingApi)
    ..registerLazySingleton<TradingRepository>(
      () => TradingRepositoryImpl(api: tradingApi),
    )
    ..registerFactory(
      () => FetchPortfolioUseCase(repository: locator<TradingRepository>()),
    )
    ..registerFactory(
      () => FetchConfigUseCase(repository: locator<TradingRepository>()),
    )
    ..registerFactory(
      () => RunPaperSessionUseCase(repository: locator<TradingRepository>()),
    )
    ..registerFactory(
      () => TradingCubit(
        fetchPortfolio: locator<FetchPortfolioUseCase>(),
        fetchConfig: locator<FetchConfigUseCase>(),
        runPaperSession: locator<RunPaperSessionUseCase>(),
      ),
    );

  final brokerApi = BrokerApi(dio: dio, baseUrl: baseUrl);

  locator
    // Broker
    ..registerSingleton<BrokerApi>(brokerApi)
    ..registerLazySingleton<BrokerRepository>(
      () => BrokerRepositoryImpl(api: brokerApi),
    )
    ..registerFactory(
      () => FetchBrokersUseCase(repository: locator<BrokerRepository>()),
    )
    ..registerFactory(
      () => FetchBrokerAccountsUseCase(repository: locator<BrokerRepository>()),
    )
    ..registerFactory(
      () => OpenBrokerAuthorizationUseCase(
        repository: locator<BrokerRepository>(),
      ),
    )
    ..registerFactory(
      () => DisconnectBrokerUseCase(repository: locator<BrokerRepository>()),
    )
    ..registerFactory(
      () => BrokerCubit(
        fetchBrokers: locator<FetchBrokersUseCase>(),
        fetchAccounts: locator<FetchBrokerAccountsUseCase>(),
        openAuthorization: locator<OpenBrokerAuthorizationUseCase>(),
        disconnectBroker: locator<DisconnectBrokerUseCase>(),
      ),
    );
}
