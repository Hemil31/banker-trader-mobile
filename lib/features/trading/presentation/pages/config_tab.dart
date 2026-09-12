import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/config_row.dart';
import '../widgets/common_widgets.dart';

class ConfigTab extends StatelessWidget {
  const ConfigTab({
    super.key,
    required this.rows,
    required this.onRefresh,
  });

  final List<ConfigRow> rows;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<ConfigRow>>{};
    for (final row in rows) {
      groups.putIfAbsent(row.group, () => []).add(row);
    }

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          if (rows.isEmpty)
            const EmptyHint(
              'Configuration is managed from the web dashboard.',
              icon: Icons.tune_outlined,
            )
          else ...[
            PillBadge.neutral('Edit from the web dashboard'),
            const SizedBox(height: AppSpace.lg),
            for (final entry in groups.entries) ...[
              SectionLabel(entry.key),
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < entry.value.length; i++) ...[
                      if (i > 0) const Divider(height: 1, indent: 16, endIndent: 16),
                      _ConfigRowTile(row: entry.value[i]),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.lg),
            ],
          ],
        ],
      ),
    );
  }
}

class _ConfigRowTile extends StatelessWidget {
  const _ConfigRowTile({required this.row});

  final ConfigRow row;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpace.lg,
        vertical: AppSpace.md,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.label, style: AppFonts.body(size: 13.5, weight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  row.key,
                  style: AppFonts.body(size: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpace.sm),
          Text(
            '${row.value ?? '—'}',
            style: AppFonts.number(size: 13.5, weight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
