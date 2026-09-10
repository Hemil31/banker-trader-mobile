import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/broker.dart';
import '../../domain/usecases/disconnect_broker_usecase.dart';
import '../../domain/usecases/fetch_broker_accounts_usecase.dart';
import '../../domain/usecases/fetch_brokers_usecase.dart';
import '../../domain/usecases/open_broker_authorization_usecase.dart';
import 'broker_state.dart';

/// Owns the broker management screen: list of connectable brokers, the user's
/// trading accounts and their connection state, plus the connect/disconnect
/// flows.
class BrokerCubit extends Cubit<BrokerState> {
  BrokerCubit({
    required FetchBrokersUseCase fetchBrokers,
    required FetchBrokerAccountsUseCase fetchAccounts,
    required OpenBrokerAuthorizationUseCase openAuthorization,
    required DisconnectBrokerUseCase disconnectBroker,
  }) : _fetchBrokers = fetchBrokers,
       _fetchAccounts = fetchAccounts,
       _openAuthorization = openAuthorization,
       _disconnectBroker = disconnectBroker,
       super(const BrokerInitial());

  final FetchBrokersUseCase _fetchBrokers;
  final FetchBrokerAccountsUseCase _fetchAccounts;
  final OpenBrokerAuthorizationUseCase _openAuthorization;
  final DisconnectBrokerUseCase _disconnectBroker;

  Future<void> load() async {
    emit(const BrokerLoading());
    try {
      final brokers = await _fetchBrokers();
      final accounts = await _fetchAccounts();
      emit(BrokerLoaded(brokers: brokers, accounts: accounts));
    } catch (error) {
      emit(BrokerError(_message(error)));
    }
  }

  /// Resolves the OAuth authorization for a broker, or throws on failure.
  Future<({Broker broker, String authorizationUrl})> prepareConnect(
    String tradingAccountId,
    String slug,
  ) async {
    final (broker, authorization) = await _openAuthorization(
      tradingAccountId,
      slug,
    );
    return (
      broker: broker,
      authorizationUrl: authorization.authorizationUrl,
    );
  }

  /// Refresh accounts after an OAuth round-trip completes.
  Future<void> afterConnect() => _refreshAccounts(
    'Broker connected successfully.',
  );

  Future<void> disconnect(String tradingAccountId) async {
    try {
      await _disconnectBroker(tradingAccountId);
      await _refreshAccounts('Broker disconnected.');
    } catch (error) {
      _emitLoadedMessage(_message(error));
    }
  }

  Future<void> _refreshAccounts([String? message]) async {
    final current = state;
    if (current is! BrokerLoaded) {
      await load();
      return;
    }
    try {
      final accounts = await _fetchAccounts();
      emit(current.copyWith(accounts: accounts, message: message));
    } catch (error) {
      emit(current.copyWith(message: _message(error)));
    }
  }

  void _emitLoadedMessage(String message) {
    final current = state;
    if (current is BrokerLoaded) {
      emit(current.copyWith(message: message));
    }
  }

  /// Dismiss the transient message after it has been shown.
  void clearMessage() {
    final current = state;
    if (current is BrokerLoaded && current.message != null) {
      emit(current.copyWith(clearMessage: true));
    }
  }

  String _message(Object error) => error.toString().split(':').last.trim();
}