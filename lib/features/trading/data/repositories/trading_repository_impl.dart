import '../../domain/entities/config_row.dart';
import '../../domain/entities/portfolio_overview.dart';
import '../../domain/repositories/trading_repository.dart';
import '../sources/trading_api.dart';

class TradingRepositoryImpl implements TradingRepository {
  TradingRepositoryImpl({required this.api});

  final TradingApi api;

  @override
  Future<PortfolioOverview> fetchPortfolio() => api.fetchPortfolio();

  @override
  Future<List<ConfigRow>> fetchConfig() => api.fetchConfig();

  @override
  Future<PaperRunResult> runPaperSession({List<int>? symbols}) async {
    final data = await api.runPaperSession(symbols: symbols);
    return PaperRunResult.fromJson(data);
  }
}
