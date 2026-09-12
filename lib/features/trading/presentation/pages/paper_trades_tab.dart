import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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
      color: AppColors.accent,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          if (trades.isEmpty)
            const EmptyHint(
              'No paper trades yet.',
              icon: Icons.receipt_long_outlined,
            )
          else ...[
            if (closed.isNotEmpty)
              Card(
                margin: const EdgeInsets.only(bottom: AppSpace.lg),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpace.lg),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Realized P&L · ${closed.length} closed',
                        style: AppFonts.body(size: 13, color: AppColors.textMuted),
                      ),
                      Text(
                        inr(total),
                        style: AppFonts.display(
                          size: 18,
                          color: total >= 0
                              ? AppColors.positive
                              : AppColors.negative,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ...trades.map((t) => TradeTile(trade: t)),
          ],
        ],
      ),
    );
  }
}
