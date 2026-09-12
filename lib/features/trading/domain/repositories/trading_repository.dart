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
      signalsGenerated: _i(json['signals_generated']),
      marketOk: json['market_ok'] as bool? ?? false,
      entered: _i(json['entered']),
      blocked: _i(json['blocked']),
      monitored: _i(json['monitored']),
      exits: _i(json['exits']),
    );
  }
}

abstract interface class TradingRepository {
  Future<PortfolioOverview> fetchPortfolio();

  Future<List<ConfigRow>> fetchConfig();

  Future<PaperRunResult> runPaperSession({List<int>? symbols});
}

int _i(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
