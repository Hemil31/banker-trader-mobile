import '../../domain/entities/broker_account.dart';
import '../../domain/repositories/broker_repository.dart';

class FetchBrokerAccountsUseCase {
  FetchBrokerAccountsUseCase({required BrokerRepository repository})
    : _repository = repository;

  final BrokerRepository _repository;

  Future<List<BrokerAccount>> call() => _repository.fetchAccounts();
}