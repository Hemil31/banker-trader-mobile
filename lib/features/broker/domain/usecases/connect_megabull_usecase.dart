import '../../domain/repositories/broker_repository.dart';

class ConnectMegaBullUseCase {
  ConnectMegaBullUseCase({required BrokerRepository repository})
    : _repository = repository;

  final BrokerRepository _repository;

  Future<void> call(String tradingAccountId, {required String apiKey}) =>
      _repository.connectMegaBull(tradingAccountId, apiKey: apiKey);
}
