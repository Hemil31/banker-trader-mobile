import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/paper_trade.dart';
import '../../domain/entities/position.dart';
import '../../domain/entities/trading_signal.dart';

const _avatarColors = [AppColors.info, AppColors.accent, AppColors.warning];

/// A small uppercase section label, e.g. "HOLDINGS", "RECENT SIGNALS".
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key, this.trailing});

  final String text;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpace.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            text.toUpperCase(),
            style: AppFonts.body(
              size: 11.5,
              weight: FontWeight.w700,
              color: AppColors.textMuted,
            ).copyWith(letterSpacing: 0.6),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// A colored pill used for status/sentiment/PnL badges.
class PillBadge extends StatelessWidget {
  const PillBadge({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.dense = false,
  });

  factory PillBadge.positive(String label, {bool dense = false}) => PillBadge(
    label: label,
    foreground: AppColors.positive,
    background: AppColors.positiveSoft,
    dense: dense,
  );

  factory PillBadge.negative(String label, {bool dense = false}) => PillBadge(
    label: label,
    foreground: AppColors.negative,
    background: AppColors.negativeSoft,
    dense: dense,
  );

  factory PillBadge.neutral(String label, {bool dense = false}) => PillBadge(
    label: label,
    foreground: AppColors.textMuted,
    background: AppColors.surfaceMuted,
    dense: dense,
  );

  factory PillBadge.signed(double value, String Function(double) format) =>
      value >= 0
      ? PillBadge.positive(format(value))
      : PillBadge.negative(format(value));

  final String label;
  final Color foreground;
  final Color background;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 8 : 10,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppFonts.number(
          size: dense ? 11 : 12,
          weight: FontWeight.w700,
          color: foreground,
        ),
      ),
    );
  }
}

/// Small colored initials badge, used as a stand-in for a symbol/broker logo.
class AvatarBadge extends StatelessWidget {
  const AvatarBadge({super.key, required this.label, this.size = 36});

  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final trimmed = label.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
    final color = _avatarColors[label.hashCode.abs() % _avatarColors.length];
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.32),
      ),
      child: Text(
        initial,
        style: AppFonts.body(
          size: size * 0.4,
          weight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
  });

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: AppColors.negativeSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 30,
                color: AppColors.negative,
              ),
            ),
            const SizedBox(height: AppSpace.lg),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.body(color: AppColors.textMuted),
            ),
            const SizedBox(height: AppSpace.lg),
            FilledButton(
              onPressed: onRetry,
              style: FilledButton.styleFrom(minimumSize: const Size(140, 44)),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyHint extends StatelessWidget {
  const EmptyHint(this.message, {super.key, this.icon = Icons.inbox_outlined});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: AppColors.textMuted),
            const SizedBox(height: AppSpace.sm),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppFonts.body(size: 13, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}

/// Headline stat card — a label, a big Fraunces number and an optional
/// supporting line underneath (e.g. "Started ₹2,00,000").
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
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
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: AppFonts.body(size: 11.5, color: AppColors.textMuted),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppFonts.display(
                size: 20,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
            if (sub != null) ...[
              const SizedBox(height: 2),
              Text(
                sub!,
                style: AppFonts.body(size: 11.5, color: AppColors.textMuted),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// A row card shared by holdings, signals and paper-trade lists: an avatar,
/// a title + caption on the left, and a colored trailing pill on the right.
class RowCard extends StatelessWidget {
  const RowCard({
    super.key,
    required this.title,
    required this.caption,
    required this.trailing,
    this.onTap,
    this.secondCaption,
  });

  final String title;
  final String caption;
  final String? secondCaption;
  final Widget trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.sm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        child: Padding(
          padding: const EdgeInsets.all(AppSpace.md),
          child: Row(
            children: [
              AvatarBadge(label: title),
              const SizedBox(width: AppSpace.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppFonts.body(size: 13.5, weight: FontWeight.w600),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      caption,
                      style: AppFonts.body(size: 11.5, color: AppColors.textMuted),
                    ),
                    if (secondCaption != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        secondCaption!,
                        style: AppFonts.body(
                          size: 11.5,
                          color: AppColors.textMuted,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              trailing,
            ],
          ),
        ),
      ),
    );
  }
}

class PositionTile extends StatelessWidget {
  const PositionTile({super.key, required this.position});

  final Position position;

  @override
  Widget build(BuildContext context) {
    return RowCard(
      title: position.symbol ?? '—',
      caption:
          'Qty ${position.quantity.toStringAsFixed(0)} · Avg ${inr(position.avgEntryPrice)}',
      secondCaption:
          'SL ${inr(position.stopLoss)} · T3 ${inr(position.target3)}',
      trailing: PillBadge.signed(
        position.unrealizedPnl,
        (v) => inr(v),
      ),
    );
  }
}

class SignalTile extends StatelessWidget {
  const SignalTile({super.key, required this.signal});

  final TradingSignal signal;

  @override
  Widget build(BuildContext context) {
    final accepted = signal.score >= 60;
    final extras = <String>[
      if (signal.proposedSl > 0) 'SL ${inr(signal.proposedSl)}',
      if (signal.proposedTarget1 > 0) 'T1 ${inr(signal.proposedTarget1)}',
      if (signal.riskRewardRatio > 0)
        'RR ${signal.riskRewardRatio.toStringAsFixed(1)}',
    ];
    return RowCard(
      title: signal.symbol ?? '—',
      caption: 'Score ${signal.score.toStringAsFixed(1)} · ${inr(signal.price)}',
      secondCaption: extras.isEmpty ? null : extras.join(' · '),
      trailing: accepted
          ? PillBadge.positive('PASS')
          : PillBadge.neutral('reject'),
    );
  }
}

class TradeTile extends StatelessWidget {
  const TradeTile({super.key, required this.trade});

  final PaperTrade trade;

  @override
  Widget build(BuildContext context) {
    return RowCard(
      title: trade.symbol,
      caption:
          '${trade.direction.toUpperCase()} · fill ${inr(trade.fillPrice)} · qty ${trade.quantity.toStringAsFixed(0)}',
      secondCaption: trade.exitReason == null
          ? trade.status
          : '${trade.status} · ${trade.exitReason}',
      trailing: PillBadge.signed(trade.pnlNet, (v) => inr(v)),
    );
  }
}
