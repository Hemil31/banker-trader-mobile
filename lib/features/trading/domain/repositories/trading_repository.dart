import '../../domain/entities/config_row.dart';
import '../../domain/entities/portfolio_overview.dart';

/// Result of a paper run session.
class PaperRunResult {
  const PaperRunResult({
    required this.signalsGenerated,
    required this.marketOk,
    required this.entered,
    required this.blocked,
    required this.monitored,
    required this.exits,
  });

  final int signalsGenerated;
  final bool marketOk;
  final int entered;
  final int blocked;
  final int monitored;
  final int exits;

  factory PaperRunResult.fromJson(Map<String, dynamic> json) {
    return PaperRunResult(
      signalsGenerated: json['signals_generated'] as int? ?? 0,
      marketOk: json['market_ok'] as bool? ?? false,
      entered: json['entered'] as int? ?? 0,
      blocked: json['blocked'] as int? ?? 0,
      monitored: json['monitored'] as int? ?? 0,
      exits: json['exits'] as int? ?? 0,
    );
  }
}

abstract interface class TradingRepository {
  Future<PortfolioOverview> fetchPortfolio();

  Future<List<ConfigRow>> fetchConfig();

  Future<PaperRunResult> runPaperSession({List<int>? symbols});
}
