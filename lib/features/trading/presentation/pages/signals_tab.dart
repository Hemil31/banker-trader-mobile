import 'package:flutter/material.dart';

import '../../domain/entities/trading_signal.dart';
import '../widgets/common_widgets.dart';

class SignalsTab extends StatelessWidget {
  const SignalsTab({
    super.key,
    required this.signals,
    required this.onRefresh,
  });

  final List<TradingSignal> signals;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (signals.isEmpty)
            const EmptyHint('No signals yet.')
          else
            ...signals.map((s) => SignalTile(signal: s)),
        ],
      ),
    );
  }
}