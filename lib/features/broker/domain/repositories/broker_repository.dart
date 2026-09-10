import '../entities/broker.dart';
import '../entities/broker_account.dart';
import '../entities/broker_authorization.dart';

/// Data contract for the broker feature. Mirrors the authenticated broker
/// endpoints in the Laravel API.
abstract class BrokerRepository {
  Future<List<Broker>> fetchBrokers();

  Future<List<BrokerAccount>> fetchAccounts();

  Future<BrokerAccount> fetchStatus(String tradingAccountId);

  Future<BrokerAuthorization> getAuthorization(String tradingAccountId, String slug);

  Future<void> disconnect(String tradingAccountId);

  Future<String> authorizeFeed(String tradingAccountId, String type);
}