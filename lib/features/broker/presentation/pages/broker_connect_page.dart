import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../trading/presentation/widgets/common_widgets.dart';
import '../../domain/entities/broker.dart';
import '../../domain/entities/broker_account.dart';
import '../state/broker_cubit.dart';
import '../state/broker_state.dart';
import 'broker_oauth_page.dart';

/// Broker management: shows the user's trading accounts and their connection
/// state, plus the connectable live brokers with connect/disconnect actions.
class BrokerConnectPage extends StatefulWidget {
  const BrokerConnectPage({super.key});

  @override
  State<BrokerConnectPage> createState() => _BrokerConnectPageState();
}

class _BrokerConnectPageState extends State<BrokerConnectPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<BrokerCubit>().load();
      }
    });
  }

  Future<void> _connect(BrokerAccount account, Broker broker) async {
    final cubit = context.read<BrokerCubit>();
    final messenger = ScaffoldMessenger.of(context);

    if (cubit.state is! BrokerLoaded ||
        (cubit.state as BrokerLoaded).accounts.isEmpty) {
      messenger.showSnackBar(
        const SnackBar(content: Text('No trading account to connect to.')),
      );
      return;
    }

    final ({String authorizationUrl, String brokerName}) prepared;
    try {
      final result = await cubit.prepareConnect(account.id, broker.slug);
      prepared = (
        authorizationUrl: result.authorizationUrl,
        brokerName: result.broker.name,
      );
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text('Could not start authorization: $error')),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    final outcome = await Navigator.of(context).push<OAuthOutcome>(
      MaterialPageRoute(
        builder: (_) => BrokerOAuthPage(
          authorizationUrl: prepared.authorizationUrl,
        ),
      ),
    );

    if (!mounted) {
      return;
    }

    if (outcome != null && outcome.success) {
      await cubit.afterConnect();
    }
    messenger.showSnackBar(
      SnackBar(
        content: Text(outcome?.message ?? '${prepared.brokerName} flow complete.'),
      ),
    );
  }

  Future<void> _disconnect(BrokerAccount account) async {
    final cubit = context.read<BrokerCubit>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Disconnect broker?'),
        content: Text(
          'Disconnect ${account.broker?.name ?? 'the broker'} from '
          '"${account.name}"? Trading will fall back to paper.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      cubit.disconnect(account.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connect trading account')),
      body: BlocBuilder<BrokerCubit, BrokerState>(
        builder: (context, state) {
          return switch (state) {
            BrokerInitial() => const SizedBox.shrink(),
            BrokerLoading() => const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
            BrokerError() => ErrorView(
              message: state.message,
              onRetry: () => context.read<BrokerCubit>().load(),
            ),
            BrokerLoaded() => _buildLoaded(context, state),
          };
        },
      ),
    );
  }

  Widget _buildLoaded(BuildContext context, BrokerLoaded state) {
    final snackbar = ScaffoldMessenger.of(context);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final message = state.message;
      if (message != null) {
        snackbar.showSnackBar(SnackBar(content: Text(message)));
        context.read<BrokerCubit>().clearMessage();
      }
    });

    // Paper always listed first, so switching back to it is just another
    // dropdown option rather than a separate disconnect control. Other paper
    // *providers* (MegaBull, ...) sit right after it — they still trade
    // virtual money, but need their own credentials like a live broker does.
    final connectableBrokers = [
      ...state.brokers.where((b) => b.slug == 'paper' && b.active),
      ...state.brokers.where((b) => b.paper && b.slug != 'paper' && b.active),
      ...state.brokers.where((b) => b.isLive),
    ];

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: () => context.read<BrokerCubit>().load(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          SectionLabel('Trading accounts'),
          if (state.accounts.isEmpty)
            const EmptyHint(
              'No trading accounts yet.',
              icon: Icons.account_balance_wallet_outlined,
            )
          else
            ...state.accounts.map(
              (account) => _AccountCard(
                account: account,
                brokers: connectableBrokers,
                onConnect: (broker) => _connect(account, broker),
                onDisconnect: () => _disconnect(account),
              ),
            ),
          const SizedBox(height: AppSpace.lg),
          PillBadge.neutral(
            'Pick Paper Trading or a broker from the dropdown, then tap the '
            'button below it.',
          ),
          const SizedBox(height: AppSpace.sm),
          Text(
            'Switching brokers drops whichever one is currently connected; '
            'switching to Paper Trading disconnects it.',
            style: AppFonts.body(size: 11.5, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatefulWidget {
  const _AccountCard({
    required this.account,
    required this.brokers,
    required this.onConnect,
    required this.onDisconnect,
  });

  final BrokerAccount account;
  final List<Broker> brokers;
  final void Function(Broker broker) onConnect;
  final VoidCallback onDisconnect;

  @override
  State<_AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<_AccountCard> {
  late String _selectedSlug;

  @override
  void initState() {
    super.initState();
    _selectedSlug = _initialSlug();
  }

  @override
  void didUpdateWidget(covariant _AccountCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.account.id != widget.account.id ||
        oldWidget.account.connected != widget.account.connected) {
      _selectedSlug = _initialSlug();
    }
  }

  /// The slug that actually reflects the account's current state: the
  /// connected broker's slug, or 'paper' when nothing is connected.
  String get _activeSlug => widget.account.connected
      ? (widget.account.broker?.slug ?? 'paper')
      : 'paper';

  String _initialSlug() {
    final available = widget.brokers.map((b) => b.slug).toSet();
    if (available.contains(_activeSlug)) {
      return _activeSlug;
    }
    return widget.brokers.isNotEmpty ? widget.brokers.first.slug : '';
  }

  Broker? get _selectedBroker {
    for (final broker in widget.brokers) {
      if (broker.slug == _selectedSlug) {
        return broker;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedBroker;
    final isSame = _selectedSlug == _activeSlug;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpace.md),
      child: Padding(
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.brokers.isEmpty)
              Text(
                'No live brokers available.',
                style: AppFonts.body(size: 12.5, color: AppColors.textMuted),
              )
            else ...[
              DropdownButtonFormField<String>(
                key: ValueKey(widget.account.id),
                initialValue: _selectedSlug,
                decoration: InputDecoration(
                  labelText: widget.account.name,
                  isDense: true,
                ),
                items: widget.brokers
                    .map(
                      (b) => DropdownMenuItem(
                        value: b.slug,
                        child: Text(b.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() => _selectedSlug = value);
                  }
                },
              ),
              const SizedBox(height: AppSpace.md),
              if (isSame)
                PillBadge(
                  label: selected?.slug == 'paper'
                      ? 'Currently in paper mode'
                      : 'Currently connected',
                  foreground: selected?.slug == 'paper'
                      ? AppColors.textMuted
                      : AppColors.positive,
                  background: selected?.slug == 'paper'
                      ? AppColors.surfaceMuted
                      : AppColors.positiveSoft,
                )
              else if (_selectedSlug == 'kotak')
                _KotakConnectForm(tradingAccountId: widget.account.id)
              else if (_selectedSlug == 'megabull')
                _MegaBullConnectForm(tradingAccountId: widget.account.id)
              else if (_selectedSlug == 'paper')
                FilledButton.icon(
                  icon: const Icon(Icons.link_off, size: 18),
                  label: const Text('Switch to paper trading'),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                  onPressed: widget.onDisconnect,
                )
              else
                FilledButton.icon(
                  icon: const Icon(Icons.link, size: 18),
                  label: Text(
                    widget.account.connected
                        ? 'Switch to ${selected?.name ?? ''}'
                        : 'Connect ${selected?.name ?? ''}',
                  ),
                  style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
                  onPressed: selected == null
                      ? null
                      : widget.account.connected
                      ? () => _confirmSwitch(context, selected)
                      : () => widget.onConnect(selected),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmSwitch(BuildContext context, Broker target) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Switch broker?'),
        content: Text(
          'Disconnect ${widget.account.broker?.name ?? 'the current broker'} '
          'and connect "${target.name}" on "${widget.account.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Switch'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      widget.onConnect(target);
    }
  }
}

/// Kotak Neo authenticates with direct credentials (no OAuth redirect):
/// mobile/UCC/TOTP log in, then MPIN validates the session, in one call.
class _KotakConnectForm extends StatefulWidget {
  const _KotakConnectForm({required this.tradingAccountId});

  final String tradingAccountId;

  @override
  State<_KotakConnectForm> createState() => _KotakConnectFormState();
}

class _KotakConnectFormState extends State<_KotakConnectForm> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _uccController = TextEditingController();
  final _totpController = TextEditingController();
  final _mpinController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _mobileController.dispose();
    _uccController.dispose();
    _totpController.dispose();
    _mpinController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<BrokerCubit>().connectKotak(
        widget.tradingAccountId,
        mobileNumber: _mobileController.text.trim(),
        ucc: _uccController.text.trim(),
        totp: _totpController.text.trim(),
        mpin: _mpinController.text.trim(),
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpace.lg),
          Text(
            'KOTAK NEO CREDENTIALS',
            style: AppFonts.body(
              size: 11,
              weight: FontWeight.w700,
              color: AppColors.textMuted,
            ).copyWith(letterSpacing: 0.5),
          ),
          const SizedBox(height: AppSpace.sm),
          TextFormField(
            controller: _mobileController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Mobile number',
              isDense: true,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: AppSpace.sm),
          TextFormField(
            controller: _uccController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'UCC / client code',
              isDense: true,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: AppSpace.sm),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _totpController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'TOTP code',
                    isDense: true,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
              const SizedBox(width: AppSpace.sm),
              Expanded(
                child: TextFormField(
                  controller: _mpinController,
                  keyboardType: TextInputType.number,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'MPIN',
                    isDense: true,
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Required' : null,
                ),
              ),
            ],
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              _error!,
              style: AppFonts.body(size: 12, color: AppColors.negative),
            ),
          ],
          const SizedBox(height: AppSpace.md),
          FilledButton(
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Verify & connect Kotak'),
          ),
        ],
      ),
    );
  }
}

/// MegaBull authenticates with a single personal api-key (generated from the
/// user's MegaBull profile) instead of an OAuth redirect. It still trades
/// virtual money — the account stays in paper mode once connected.
class _MegaBullConnectForm extends StatefulWidget {
  const _MegaBullConnectForm({required this.tradingAccountId});

  final String tradingAccountId;

  @override
  State<_MegaBullConnectForm> createState() => _MegaBullConnectFormState();
}

class _MegaBullConnectFormState extends State<_MegaBullConnectForm> {
  final _formKey = GlobalKey<FormState>();
  final _apiKeyController = TextEditingController();
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await context.read<BrokerCubit>().connectMegaBull(
        widget.tradingAccountId,
        apiKey: _apiKeyController.text.trim(),
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: AppSpace.lg),
          Text(
            'MEGABULL API KEY',
            style: AppFonts.body(
              size: 11,
              weight: FontWeight.w700,
              color: AppColors.textMuted,
            ).copyWith(letterSpacing: 0.5),
          ),
          const SizedBox(height: AppSpace.xs),
          Text(
            'Generate this from your MegaBull profile at trade.megabull.in. '
            'Keys expire after 1 month and can be regenerated there.',
            style: AppFonts.body(size: 11.5, color: AppColors.textMuted),
          ),
          const SizedBox(height: AppSpace.sm),
          TextFormField(
            controller: _apiKeyController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'API key',
              isDense: true,
            ),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Required' : null,
          ),
          if (_error != null) ...[
            const SizedBox(height: AppSpace.sm),
            Text(
              _error!,
              style: AppFonts.body(size: 12, color: AppColors.negative),
            ),
          ],
          const SizedBox(height: AppSpace.md),
          FilledButton(
            onPressed: _busy ? null : _submit,
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(44)),
            child: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Verify & connect MegaBull'),
          ),
        ],
      ),
    );
  }
}
