import '../../domain/repositories/broker_repository.dart';

class DisconnectBrokerUseCase {
  DisconnectBrokerUseCase({required BrokerRepository repository})
    : _repository = repository;

  final BrokerRepository _repository;

  Future<void> call(String tradingAccountId) =>
      _repository.disconnect(tradingAccountId);
}