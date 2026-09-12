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

  /// Connects a Kotak Neo account directly with credentials (mobile/UCC/TOTP
  /// then MPIN) instead of the OAuth redirect other brokers use.
  Future<void> connectKotak(
    String tradingAccountId, {
    required String mobileNumber,
    required String ucc,
    required String totp,
    required String mpin,
  });

  /// Connects a MegaBull paper-trading account with the user's own api-key
  /// (no OAuth redirect — MegaBull authenticates every request via header).
  Future<void> connectMegaBull(String tradingAccountId, {required String apiKey});
}