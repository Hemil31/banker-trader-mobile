import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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
      color: AppColors.accent,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          if (state.sessionMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpace.md),
              child: PillBadge.neutral(state.sessionMessage!),
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
    final isPaper = o.account.mode != 'live';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PillBadge(
          label: isPaper ? 'PAPER ACCOUNT' : 'LIVE ACCOUNT · ${o.account.name}',
          foreground: isPaper ? AppColors.warning : AppColors.info,
          background: isPaper ? AppColors.warningSoft : AppColors.infoSoft,
        ),
        const SizedBox(height: AppSpace.md),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(AppSpace.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total equity',
                  style: AppFonts.body(size: 12, color: AppColors.textMuted),
                ),
                const SizedBox(height: 6),
                Text(inr(o.portfolio.netEquity), style: AppFonts.display(size: 32)),
                const SizedBox(height: 6),
                Text(
                  'Started ${inr(o.account.startingCapital)}',
                  style: AppFonts.body(size: 12.5, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: AppSpace.md),
        Row(
          children: [
            Expanded(
              child: StatCard(
                label: 'Available cash',
                value: inr(o.account.availableCash),
              ),
            ),
            const SizedBox(width: AppSpace.sm),
            Expanded(
              child: StatCard(
                label: 'Invested',
                value: inr(o.portfolio.invested),
                sub: '${o.portfolio.openPositionsCount} open',
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpace.sm),
        StatCard(
          label: 'Unrealized P&L',
          value: inr(o.portfolio.unrealized),
          sub: '${o.marketBars} market bars tracked',
          valueColor: o.portfolio.unrealized >= 0
              ? AppColors.positive
              : AppColors.negative,
        ),
        const SizedBox(height: AppSpace.xl),
        SectionLabel('Open positions'),
        if (o.openPositions.isEmpty)
          const EmptyHint(
            'No open positions — run a paper session.',
            icon: Icons.candlestick_chart_outlined,
          )
        else
          ...o.openPositions.map((p) => PositionTile(position: p)),
        const SizedBox(height: AppSpace.lg),
        SectionLabel('Recent signals'),
        if (o.recentSignals.isEmpty)
          const EmptyHint('No signals yet.', icon: Icons.query_stats_outlined)
        else
          ...o.recentSignals.take(5).map((s) => SignalTile(signal: s)),
      ],
    );
  }
}
