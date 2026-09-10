class Position {
  const Position({
    required this.id,
    required this.symbol,
    required this.status,
    required this.quantity,
    required this.avgEntryPrice,
    required this.entryValue,
    required this.stopLoss,
    required this.target1,
    required this.target2,
    required this.target3,
    required this.currentStop,
    required this.unrealizedPnl,
    required this.realizedPnlNet,
    required this.netPnl,
    required this.closeReason,
    required this.exitPrice,
    required this.openedAt,
    required this.closedAt,
  });

  final int id;
  final String? symbol;
  final String status;
  final double quantity;
  final double avgEntryPrice;
  final double entryValue;
  final double stopLoss;
  final double target1;
  final double target2;
  final double target3;
  final double currentStop;
  final double unrealizedPnl;
  final double realizedPnlNet;
  final double netPnl;
  final String? closeReason;
  final double exitPrice;
  final String? openedAt;
  final String? closedAt;

  bool get isOpen => status == 'open';

  factory Position.fromJson(Map<String, dynamic> json) {
    return Position(
      id: json['id'] as int? ?? 0,
      symbol: json['symbol'] as String?,
      status: json['status'] as String? ?? 'unknown',
      quantity: _d(json['quantity']),
      avgEntryPrice: _d(json['avg_entry_price']),
      entryValue: _d(json['entry_value']),
      stopLoss: _d(json['stop_loss']),
      target1: _d(json['target1']),
      target2: _d(json['target2']),
      target3: _d(json['target3']),
      currentStop: _d(json['current_stop']),
      unrealizedPnl: _d(json['unrealized_pnl']),
      realizedPnlNet: _d(json['realized_pnl_net']),
      netPnl: _d(json['net_pnl']),
      closeReason: json['close_reason'] as String?,
      exitPrice: _d(json['exit_price']),
      openedAt: json['opened_at'] as String?,
      closedAt: json['closed_at'] as String?,
    );
  }
}

double _d(Object? value) => (value as num?)?.toDouble() ?? 0;
