import '../../domain/entities/broker.dart';
import '../../domain/repositories/broker_repository.dart';

class FetchBrokersUseCase {
  FetchBrokersUseCase({required BrokerRepository repository})
    : _repository = repository;

  final BrokerRepository _repository;

  Future<List<Broker>> call() => _repository.fetchBrokers();
}