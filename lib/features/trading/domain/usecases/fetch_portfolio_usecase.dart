import '../../domain/entities/portfolio_overview.dart';
import '../repositories/trading_repository.dart';

class FetchPortfolioUseCase {
  FetchPortfolioUseCase({required TradingRepository repository})
    : _repository = repository;

  final TradingRepository _repository;

  Future<PortfolioOverview> call() => _repository.fetchPortfolio();
}
