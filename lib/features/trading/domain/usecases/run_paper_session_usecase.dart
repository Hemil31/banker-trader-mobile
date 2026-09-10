import '../../domain/repositories/trading_repository.dart';

class RunPaperSessionUseCase {
  RunPaperSessionUseCase({required TradingRepository repository})
    : _repository = repository;

  final TradingRepository _repository;

  Future<PaperRunResult> call({List<int>? symbols}) =>
      _repository.runPaperSession(symbols: symbols);
}
