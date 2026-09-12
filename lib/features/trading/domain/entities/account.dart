/// Paper trading account summary as exposed by `GET /api/portfolio.
class Account {
  const Account({
    required this.id,
    required this.name,
    required this.mode,
    required this.startingCapital,
    required this.availableCash,
    required this.investedAmount,
  });

  final String id;
  final String name;
  final String mode;
  final double startingCapital;
  final double availableCash;
  final double investedAmount;

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Paper Trading',
      mode: json['mode'] as String? ?? 'paper',
      startingCapital: _d(json['starting_capital']),
      availableCash: _d(json['available_cash']),
      investedAmount: _d(json['invested_amount']),
    );
  }
}

double _d(Object? value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}
