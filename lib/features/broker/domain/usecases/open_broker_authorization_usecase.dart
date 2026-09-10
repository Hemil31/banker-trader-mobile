import '../../domain/entities/broker.dart';
import '../../domain/entities/broker_authorization.dart';
import '../../domain/repositories/broker_repository.dart';

class OpenBrokerAuthorizationUseCase {
  OpenBrokerAuthorizationUseCase({required BrokerRepository repository})
    : _repository = repository;

  final BrokerRepository _repository;

  /// Resolves the connectable broker + OAuth URL for an account.
  ///
  /// Returns a pair `(Broker, BrokerAuthorization)` — the broker so all live
  /// brokers of an account are presented in the UI.
  Future<(Broker, BrokerAuthorization)> call(
    String tradingAccountId,
    String slug,
  ) async {
    final brokers = await _repository.fetchBrokers();
    final broker = brokers.firstWhere(
      (b) => b.slug == slug,
      orElse: () => Broker(
        slug: slug,
        name: slug,
        paper: false,
        active: true,
      ),
    );
    final authorization = await _repository.getAuthorization(
      tradingAccountId,
      slug,
    );
    return (broker, authorization);
  }
}