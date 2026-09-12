import '../repositories/trading_repository.dart';

class UpdateConfigUseCase {
  UpdateConfigUseCase({required TradingRepository repository})
    : _repository = repository;

  final TradingRepository _repository;

  Future<Object?> call(String key, Object value) =>
      _repository.updateConfig(key, value);
}
