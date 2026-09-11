import 'package:flutter/material.dart';

import '../../domain/entities/paper_trade.dart';
import '../widgets/common_widgets.dart';

class PaperTradesTab extends StatelessWidget {
  const PaperTradesTab({
    super.key,
    required this.trades,
    required this.onRefresh,
  });

  final List<PaperTrade> trades;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final closed = trades.where((t) => t.isClosed).toList(growable: false);
    final total = closed.fold<double>(0, (sum, t) => sum + t.pnlNet);

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (trades.isEmpty)
            const EmptyHint('No paper trades yet.')
          else ...[
            if (closed.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Realized P&L: ${inr(total)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ...trades.map(_tradeCard),
          ],
        ],
      ),
    );
  }

  Widget _tradeCard(PaperTrade trade) {
    final color = trade.pnlNet >= 0 ? Colors.green.shade700 : Colors.red.shade700;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(trade.symbol),
        subtitle: Text(
          'fill ${inr(trade.fillPrice)} · qty ${trade.quantity} · '
          '${trade.status}${trade.exitReason != null ? ' · ${trade.exitReason}' : ''}',
        ),
        trailing: Text(
          inr(trade.pnlNet),
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}