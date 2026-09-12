import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../broker/presentation/state/broker_cubit.dart';
import '../../../news/presentation/pages/news_tab.dart';
import '../../../news/presentation/state/news_cubit.dart';
import '../../../profile/presentation/pages/profile_tab.dart';
import '../state/trading_cubit.dart';
import '../state/trading_state.dart';
import '../widgets/common_widgets.dart';
import 'config_tab.dart';
import 'overview_tab.dart';
import 'paper_trades_tab.dart';
import 'signals_tab.dart';

/// Authenticated shell with bottom-tab navigation:
/// Home (overview), News, Signals, Paper trades, Config and Profile.
class TradingHomePage extends StatefulWidget {
  const TradingHomePage({super.key});

  @override
  State<TradingHomePage> createState() => _TradingHomePageState();
}

class _TradingHomePageState extends State<TradingHomePage> {
  int _index = 0;

  static const _titles = [
    'Home',
    'News',
    'Signals',
    'Paper trades',
    'Config',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TradingCubit>().load();
        context.read<BrokerCubit>().load();
      }
    });
  }

  void _selectTab(int index) {
    setState(() => _index = index);
    if (index == 1) {
      context.read<NewsCubit>().load();
    } else if (index == 4) {
      context.read<TradingCubit>().load(withConfig: true);
    } else if (index == 5) {
      context.read<BrokerCubit>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final running = context.select<TradingCubit, bool>(
      (c) =>
          c.state is TradingLoaded && (c.state as TradingLoaded).runningSession,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (_index == 0) ...[
            IconButton.filled(
              tooltip: 'Run paper session',
              style: IconButton.styleFrom(
                backgroundColor: AppColors.accentSoft,
                foregroundColor: AppColors.accent,
              ),
              onPressed: running
                  ? null
                  : () => context.read<TradingCubit>().runSession(),
              icon: running
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    )
                  : const Icon(Icons.play_arrow_rounded),
            ),
            const SizedBox(width: AppSpace.sm),
            IconButton(
              tooltip: 'Profile',
              onPressed: () => _selectTab(5),
              icon: const Icon(Icons.person_outline),
            ),
            const SizedBox(width: AppSpace.sm),
          ],
        ],
      ),
      body: BlocBuilder<TradingCubit, TradingState>(
        builder: (context, state) {
          return switch (state) {
            TradingInitial() => const SizedBox.shrink(),
            TradingLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            TradingError() => ErrorView(
              message: state.message,
              onRetry: () => context.read<TradingCubit>().load(),
            ),
            TradingLoaded() => IndexedStack(
              index: _index,
              children: [
                OverviewTab(
                  state: state,
                  onRefresh: () => context.read<TradingCubit>().load(),
                ),
                NewsTab(
                  onRefresh: () => context.read<NewsCubit>().load(),
                ),
                SignalsTab(
                  signals: state.overview.recentSignals,
                  onRefresh: () => context.read<TradingCubit>().load(),
                ),
                PaperTradesTab(
                  trades: state.overview.recentPaperTrades,
                  onRefresh: () => context.read<TradingCubit>().load(),
                ),
                ConfigTab(
                  state: state,
                  onRefresh: () =>
                      context.read<TradingCubit>().load(withConfig: true),
                ),
                const ProfileTab(),
              ],
            ),
          };
        },
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(12, 0, 12, 10),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.textPrimary.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: NavigationBar(
            selectedIndex: _index,
            onDestinationSelected: _selectTab,
            height: 64,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.home_outlined),
                selectedIcon: Icon(Icons.home),
                label: 'Home',
              ),
              NavigationDestination(
                icon: Icon(Icons.newspaper_outlined),
                selectedIcon: Icon(Icons.newspaper),
                label: 'News',
              ),
              NavigationDestination(
                icon: Icon(Icons.query_stats_outlined),
                selectedIcon: Icon(Icons.query_stats),
                label: 'Signals',
              ),
              NavigationDestination(
                icon: Icon(Icons.receipt_long_outlined),
                selectedIcon: Icon(Icons.receipt_long),
                label: 'Trades',
              ),
              NavigationDestination(
                icon: Icon(Icons.tune_outlined),
                selectedIcon: Icon(Icons.tune),
                label: 'Config',
              ),
              NavigationDestination(
                icon: Icon(Icons.person_outline),
                selectedIcon: Icon(Icons.person),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}