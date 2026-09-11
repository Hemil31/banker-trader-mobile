import 'package:flutter/material.dart';

import '../../domain/entities/portfolio_overview.dart';
import '../state/trading_state.dart';
import '../widgets/common_widgets.dart';

class OverviewTab extends StatelessWidget {
  const OverviewTab({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  final TradingLoaded state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (state.sessionMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                state.sessionMessage!,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
          _OverviewBody(overview: state.overview),
        ],
      ),
    );
  }
}

class _OverviewBody extends StatelessWidget {
  const _OverviewBody({required this.overview});

  final PortfolioOverview overview;

  @override
  Widget build(BuildContext context) {
    final o = overview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Net equity',
                value: inr(o.portfolio.netEquity),
                sub: 'Started ${inr(o.account.startingCapital)}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                label: 'Available cash',
                value: inr(o.account.availableCash),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Invested',
                value: inr(o.portfolio.invested),
                sub: '${o.portfolio.openPositionsCount} open',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: StatCard(
                label: 'Unrealized',
                value: inr(o.portfolio.unrealized),
                sub: '${o.marketBars} bars',
                valueColor: o.portfolio.unrealized >= 0
                    ? Colors.green.shade700
                    : Colors.red.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text('Open positions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (o.openPositions.isEmpty)
          const EmptyHint('No open positions — run a paper session.')
        else
          ...o.openPositions.map((p) => PositionTile(position: p)),
        const SizedBox(height: 20),
        Text('Recent signals', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (o.recentSignals.isEmpty)
          const EmptyHint('No signals yet.')
        else
          ...o.recentSignals.take(5).map((s) => SignalTile(signal: s)),
      ],
    );
  }
}