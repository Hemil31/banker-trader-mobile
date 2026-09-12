import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/config_row.dart';
import '../state/trading_cubit.dart';
import '../state/trading_state.dart';
import '../widgets/common_widgets.dart';

/// Config row types editable from the mobile app — mirrors what used to be
/// editable on the (now removed) web dashboard. `string`/`array`/`json` rows
/// stay read-only.
const _editableTypes = {'integer', 'float', 'boolean'};

class ConfigTab extends StatelessWidget {
  const ConfigTab({
    super.key,
    required this.state,
    required this.onRefresh,
  });

  final TradingLoaded state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final rows = state.config;
    final groups = <String, List<ConfigRow>>{};
    for (final row in rows) {
      groups.putIfAbsent(row.group, () => []).add(row);
    }

    final configMessage = state.configMessage;
    if (configMessage != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(configMessage)));
        context.read<TradingCubit>().clearConfigMessage();
      });
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
              'No configuration available yet.',
              icon: Icons.tune_outlined,
            )
          else
            for (final entry in groups.entries) ...[
              SectionLabel(entry.key),
              Card(
                child: Column(
                  children: [
                    for (var i = 0; i < entry.value.length; i++) ...[
                      if (i > 0)
                        const Divider(height: 1, indent: 16, endIndent: 16),
                      _ConfigRowTile(
                        key: ValueKey(entry.value[i].key),
                        row: entry.value[i],
                        isUpdating: state.updatingConfigKeys.contains(
                          entry.value[i].key,
                        ),
                        onUpdate: (value) => context
                            .read<TradingCubit>()
                            .updateConfig(entry.value[i].key, value),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpace.lg),
            ],
        ],
      ),
    );
  }
}

class _ConfigRowTile extends StatelessWidget {
  const _ConfigRowTile({
    super.key,
    required this.row,
    required this.isUpdating,
    required this.onUpdate,
  });

  final ConfigRow row;
  final bool isUpdating;
  final ValueChanged<Object> onUpdate;

  bool get _editable => row.isEditable && _editableTypes.contains(row.type);

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
          if (!_editable)
            Text(
              '${row.value ?? '—'}',
              style: AppFonts.number(size: 13.5, weight: FontWeight.w700),
            )
          else if (row.type == 'boolean')
            isUpdating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Switch(
                    value: row.value == true,
                    onChanged: onUpdate,
                  )
          else
            _NumericValueEditor(
              row: row,
              isUpdating: isUpdating,
              onSave: onUpdate,
            ),
        ],
      ),
    );
  }
}

/// Inline numeric editor for `integer`/`float` rows — edits are local until
/// the save button (or submit) fires the update, no auto-save on keystroke.
class _NumericValueEditor extends StatefulWidget {
  const _NumericValueEditor({
    required this.row,
    required this.isUpdating,
    required this.onSave,
  });

  final ConfigRow row;
  final bool isUpdating;
  final ValueChanged<Object> onSave;

  @override
  State<_NumericValueEditor> createState() => _NumericValueEditorState();
}

class _NumericValueEditorState extends State<_NumericValueEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.row.value ?? ''}');
  }

  @override
  void didUpdateWidget(covariant _NumericValueEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isUpdating && oldWidget.row.value != widget.row.value) {
      _controller.text = '${widget.row.value ?? ''}';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final raw = _controller.text.trim();
    final value = widget.row.type == 'float'
        ? double.tryParse(raw)
        : int.tryParse(raw);
    if (value == null) return;
    widget.onSave(value);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 130,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              enabled: !widget.isUpdating,
              textAlign: TextAlign.right,
              keyboardType: TextInputType.numberWithOptions(
                decimal: widget.row.type == 'float',
                signed: true,
              ),
              style: AppFonts.number(size: 13.5, weight: FontWeight.w700),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 4),
          widget.isUpdating
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : IconButton(
                  icon: const Icon(Icons.check_circle_outline, size: 20),
                  color: AppColors.accent,
                  tooltip: 'Save',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: _submit,
                ),
        ],
      ),
    );
  }
}
