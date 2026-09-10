import '../../domain/entities/broker.dart';
import '../../domain/entities/broker_account.dart';
import '../../domain/entities/broker_authorization.dart';
import '../../domain/repositories/broker_repository.dart';
import '../sources/broker_api.dart';

class BrokerRepositoryImpl implements BrokerRepository {
  BrokerRepositoryImpl({required BrokerApi api}) : _api = api;

  final BrokerApi _api;

  @override
  Future<List<Broker>> fetchBrokers() => _api.fetchBrokers();

  @override
  Future<List<BrokerAccount>> fetchAccounts() => _api.fetchAccounts();

  @override
  Future<BrokerAccount> fetchStatus(String tradingAccountId) =>
      _api.fetchStatus(tradingAccountId);

  @override
  Future<BrokerAuthorization> getAuthorization(
    String tradingAccountId,
    String slug,
  ) => _api.getAuthorization(tradingAccountId, slug);

  @override
  Future<void> disconnect(String tradingAccountId) =>
      _api.disconnect(tradingAccountId);

  @override
  Future<String> authorizeFeed(String tradingAccountId, String type) =>
      _api.authorizeFeed(tradingAccountId, type);
}