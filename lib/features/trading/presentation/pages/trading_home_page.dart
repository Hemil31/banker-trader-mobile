import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../authentication/presentation/state/auth_cubit.dart';
import '../../../broker/presentation/pages/broker_connect_page.dart';
import '../../domain/entities/config_row.dart';
import '../../domain/entities/paper_trade.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/trading_signal.dart';
import '../state/trading_cubit.dart';
import '../state/trading_state.dart';

class TradingHomePage extends StatefulWidget {
  const TradingHomePage({super.key});

  @override
  State<TradingHomePage> createState() => _TradingHomePageState();
}

class _TradingHomePageState extends State<TradingHomePage> {
  int _tab = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TradingCubit>().load();
      }
    });
  }

  void _selectTab(int index) {
    setState(() => _tab = index);
    if (index == 3) {
      context.read<TradingCubit>().load(withConfig: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final running = context.select<TradingCubit, bool>(
      (c) =>
          c.state is TradingLoaded && (c.state as TradingLoaded).runningSession,
    );

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BankerTrader'),
          actions: [
            IconButton(
              tooltip: 'Broker settings',
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const BrokerConnectPage(),
                ),
              ),
              icon: const Icon(Icons.account_balance_wallet_outlined),
            ),
            IconButton(
              tooltip: 'Run paper session',
              onPressed: running
                  ? null
                  : () => context.read<TradingCubit>().runSession(),
              icon: running
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.play_circle_outline),
            ),
            IconButton(
              tooltip: 'Logout',
              onPressed: () => context.read<AuthCubit>().logout(),
              icon: const Icon(Icons.logout),
            ),
          ],
          bottom: TabBar(
            onTap: _selectTab,
            tabs: const [
              Tab(text: 'Overview'),
              Tab(text: 'Signals'),
              Tab(text: 'Paper trades'),
              Tab(text: 'Config'),
            ],
          ),
        ),
        body: BlocBuilder<TradingCubit, TradingState>(
          builder: (context, state) {
            return switch (state) {
              TradingInitial() => const SizedBox.shrink(),
              TradingLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              TradingError() => _ErrorView(message: state.message),
              TradingLoaded() => _buildTab(context, state),
            };
          },
        ),
      ),
    );
  }

  Widget _buildTab(BuildContext context, TradingLoaded state) {
    return RefreshIndicator(
      onRefresh: () => context.read<TradingCubit>().load(withConfig: _tab == 3),
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
          switch (_tab) {
            0 => _OverviewTab(state: state),
            1 => _SignalsTab(signals: state.overview.recentSignals),
            2 => _PaperTradesTab(trades: state.overview.recentPaperTrades),
            _ => _ConfigTab(rows: state.config),
          },
        ],
      ),
    );
  }
}

String inr(num value) => '₹${value.toStringAsFixed(0)}';

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => context.read<TradingCubit>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.state});

  final TradingLoaded state;

  @override
  Widget build(BuildContext context) {
    final o = state.overview;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'Net equity',
                value: inr(o.portfolio.netEquity),
                sub: 'Started ${inr(o.account.startingCapital)}',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
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
              child: _StatCard(
                label: 'Invested',
                value: inr(o.portfolio.invested),
                sub: '${o.portfolio.openPositionsCount} open',
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCard(
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
          const _EmptyHint('No open positions — run a paper session.')
        else
          ...o.openPositions.map((p) => _PositionTile(position: p)),
        const SizedBox(height: 20),
        Text('Recent signals', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (o.recentSignals.isEmpty)
          const _EmptyHint('No signals yet.')
        else
          ...o.recentSignals.take(5).map((s) => _SignalTile(signal: s)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.sub,
    this.valueColor,
  });

  final String label;
  final String value;
  final String? sub;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: valueColor),
            ),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(sub!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ),
      ),
    );
  }
}

class _PositionTile extends StatelessWidget {
  const _PositionTile({required this.position});

  final Position position;

  @override
  Widget build(BuildContext context) {
    final color = position.unrealizedPnl >= 0
        ? Colors.green.shade700
        : Colors.red.shade700;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(position.symbol ?? '—'),
        subtitle: Text(
          'Qty ${position.quantity} · avg ${inr(position.avgEntryPrice)} · '
          'SL ${inr(position.stopLoss)} · T3 ${inr(position.target3)}',
        ),
        trailing: Text(
          inr(position.unrealizedPnl),
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _SignalTile extends StatelessWidget {
  const _SignalTile({required this.signal});

  final TradingSignal signal;

  @override
  Widget build(BuildContext context) {
    final accepted = signal.score >= 60;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(signal.symbol ?? '—'),
        subtitle: Text(
          'score ${signal.score.toStringAsFixed(1)} · price ${inr(signal.price)}',
        ),
        trailing: Text(
          accepted ? 'PASS' : 'reject',
          style: TextStyle(
            color: accepted ? Colors.green.shade700 : Colors.grey,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _SignalsTab extends StatelessWidget {
  const _SignalsTab({required this.signals});

  final List<TradingSignal> signals;

  @override
  Widget build(BuildContext context) {
    if (signals.isEmpty) {
      return const _EmptyHint('No signals yet.');
    }
    return Column(
      children: signals
          .map((s) => _SignalTile(signal: s))
          .toList(growable: false),
    );
  }
}

class _PaperTradesTab extends StatelessWidget {
  const _PaperTradesTab({required this.trades});

  final List<PaperTrade> trades;

  @override
  Widget build(BuildContext context) {
    if (trades.isEmpty) {
      return const _EmptyHint('No paper trades yet.');
    }
    final closed = trades.where((t) => t.isClosed);
    final total = closed.fold<double>(0, (sum, t) => sum + t.pnlNet);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (closed.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              'Realized P&L: ${inr(total)}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ...trades.map((t) {
          final color = t.pnlNet >= 0
              ? Colors.green.shade700
              : Colors.red.shade700;
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(t.symbol),
              subtitle: Text(
                'fill ${inr(t.fillPrice)} · qty ${t.quantity} · '
                '${t.status}${t.exitReason != null ? ' · ${t.exitReason}' : ''}',
              ),
              trailing: Text(
                inr(t.pnlNet),
                style: TextStyle(color: color, fontWeight: FontWeight.w600),
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ConfigTab extends StatelessWidget {
  const _ConfigTab({required this.rows});

  final List<ConfigRow> rows;

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) {
      return const _EmptyHint(
        'Configuration is managed from the web dashboard.',
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Edit from the web dashboard',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const SizedBox(height: 8),
        ...rows.map(
          (row) => Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
              title: Text(row.key, style: const TextStyle(fontSize: 13)),
              subtitle: Text(row.label),
              trailing: Text(
                '${row.value ?? ''}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint(this.message);

  final String message;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Center(
        child: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      ),
    );
  }
}
