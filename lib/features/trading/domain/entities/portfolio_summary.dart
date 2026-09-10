/// Aggregate portfolio numbers from `overview.portfolio`.
class PortfolioSummary {
  const PortfolioSummary({
    required this.invested,
    required this.unrealized,
    required this.realized,
    required this.grossEquity,
    required this.netEquity,
    required this.openPositionsCount,
  });

  final double invested;
  final double unrealized;
  final double realized;
  final double grossEquity;
  final double netEquity;
  final int openPositionsCount;

  factory PortfolioSummary.fromJson(Map<String, dynamic> json) {
    return PortfolioSummary(
      invested: _d(json['invested']),
      unrealized: _d(json['unrealized']),
      realized: _d(json['realized']),
      grossEquity: _d(json['gross_equity']),
      netEquity: _d(json['net_equity']),
      openPositionsCount: json['open_positions_count'] as int? ?? 0,
    );
  }
}

double _d(Object? value) => (value as num?)?.toDouble() ?? 0;
