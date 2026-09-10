import '../../domain/entities/config_row.dart';
import '../../domain/repositories/trading_repository.dart';

class FetchConfigUseCase {
  FetchConfigUseCase({required TradingRepository repository})
    : _repository = repository;

  final TradingRepository _repository;

  Future<List<ConfigRow>> call() => _repository.fetchConfig();
}
