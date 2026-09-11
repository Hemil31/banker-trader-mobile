import 'package:flutter/material.dart';

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
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (rows.isEmpty)
            const EmptyHint(
              'Configuration is managed from the web dashboard.',
            )
          else ...[
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
        ],
      ),
    );
  }
}