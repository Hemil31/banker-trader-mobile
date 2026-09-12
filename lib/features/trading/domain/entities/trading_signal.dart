class TradingSignal {
  const TradingSignal({
    required this.id,
    required this.symbol,
    required this.signalDate,
    required this.price,
    required this.score,
    required this.proposedSl,
    required this.proposedTarget1,
    required this.proposedTarget3,
    required this.riskRewardRatio,
    required this.status,
  });

  final String id;
  final String? symbol;
  final String? signalDate;
  final double price;
  final double score;
  final double proposedSl;
  final double proposedTarget1;
  final double proposedTarget3;
  final double riskRewardRatio;
  final String status;

  factory TradingSignal.fromJson(Map<String, dynamic> json) {
    return TradingSignal(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String?,
      signalDate: json['signal_date'] as String?,
      price: _d(json['price']),
      score: _d(json['score']),
      proposedSl: _d(json['proposed_sl']),
      proposedTarget1: _d(json['proposed_target1']),
      proposedTarget3: _d(json['proposed_target3']),
      riskRewardRatio: _d(json['risk_reward_ratio']),
      status: json['status'] as String? ?? 'candidate',
    );
  }
}

double _d(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
