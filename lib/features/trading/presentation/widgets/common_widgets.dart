import 'package:flutter/material.dart';

import '../../domain/entities/position.dart';
import '../../domain/entities/trading_signal.dart';

String inr(num value) => '₹${value.toStringAsFixed(0)}';

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
            const Icon(Icons.error_outline, size: 48),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

class EmptyHint extends StatelessWidget {
  const EmptyHint(this.message, {super.key});

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

class PositionTile extends StatelessWidget {
  const PositionTile({super.key, required this.position});

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

class SignalTile extends StatelessWidget {
  const SignalTile({super.key, required this.signal});

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