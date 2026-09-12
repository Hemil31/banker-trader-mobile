import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
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
      color: AppColors.accent,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          if (signals.isEmpty)
            const EmptyHint(
              'No signals yet.',
              icon: Icons.query_stats_outlined,
            )
          else ...[
            SectionLabel('${signals.length} signals'),
            ...signals.map((s) => SignalTile(signal: s)),
          ],
        ],
      ),
    );
  }
}
