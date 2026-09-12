class PaperTrade {
  const PaperTrade({
    required this.id,
    required this.symbol,
    required this.direction,
    required this.fillPrice,
    required this.quantity,
    required this.stopLoss,
    required this.target,
    required this.pnlNet,
    required this.status,
    required this.exitReason,
    required this.executedAt,
  });

  final String id;
  final String symbol;
  final String direction;
  final double fillPrice;
  final double quantity;
  final double stopLoss;
  final double target;
  final double pnlNet;
  final String status;
  final String? exitReason;
  final String? executedAt;

  bool get isClosed => status == 'closed';

  factory PaperTrade.fromJson(Map<String, dynamic> json) {
    return PaperTrade(
      id: json['id'] as String? ?? '',
      symbol: json['symbol'] as String? ?? '—',
      direction: json['direction'] as String? ?? 'buy',
      fillPrice: _d(json['fill_price']),
      quantity: _d(json['quantity']),
      stopLoss: _d(json['stop_loss']),
      target: _d(json['target']),
      pnlNet: _d(json['pnl_net']),
      status: json['status'] as String? ?? 'open',
      exitReason: json['exit_reason'] as String?,
      executedAt: json['executed_at'] as String?,
    );
  }
}

double _d(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
