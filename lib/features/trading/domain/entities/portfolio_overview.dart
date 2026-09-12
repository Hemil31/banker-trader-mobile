import 'account.dart';
import 'paper_trade.dart';
import 'portfolio_summary.dart';
import 'position.dart';
import 'trading_signal.dart';

/// Full payload of `GET /api/portfolio`.
class PortfolioOverview {
  const PortfolioOverview({
    required this.account,
    required this.portfolio,
    required this.openPositions,
    required this.recentSignals,
    required this.recentPaperTrades,
    required this.marketBars,
  });

  final Account account;
  final PortfolioSummary portfolio;
  final List<Position> openPositions;
  final List<TradingSignal> recentSignals;
  final List<PaperTrade> recentPaperTrades;
  final int marketBars;

  factory PortfolioOverview.fromJson(Map<String, dynamic> json) {
    final account = json['account'] as Map<String, dynamic>? ?? const {};
    final portfolio = json['portfolio'] as Map<String, dynamic>? ?? const {};
    return PortfolioOverview(
      account: Account.fromJson(account),
      portfolio: PortfolioSummary.fromJson(portfolio),
      openPositions: _list(
        json['open_positions'],
      ).map((e) => Position.fromJson(e)).toList(),
      recentSignals: _list(
        json['recent_signals'],
      ).map((e) => TradingSignal.fromJson(e)).toList(),
      recentPaperTrades: _list(
        json['recent_paper_trades'],
      ).map((e) => PaperTrade.fromJson(e)).toList(),
      marketBars: _i(json['market_bars']),
    );
  }
}

List<Map<String, dynamic>> _list(Object? value) {
  if (value is! List) {
    return const [];
  }
  return value.whereType<Map<String, dynamic>>().toList(growable: false);
}

int _i(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}
