import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
      appBar: AppBar(title: const Text('Broker settings')),
      body: BlocBuilder<BrokerCubit, BrokerState>(
        builder: (context, state) {
          return switch (state) {
            BrokerInitial() => const SizedBox.shrink(),
            BrokerLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            BrokerError() => _ErrorView(message: state.message),
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

    final liveBrokers = state.brokers.where((b) => b.isLive).toList();
    final connectedSlugs = state.accounts
        .where((a) => a.connected)
        .map((a) => a.broker?.slug)
        .whereType<String>()
        .toSet();

    return RefreshIndicator(
      onRefresh: () => context.read<BrokerCubit>().load(),
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Trading accounts',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (state.accounts.isEmpty)
            const _EmptyHint('No trading accounts yet.')
          else
            ...state.accounts.map(
              (account) => _AccountCard(
                account: account,
                onDisconnect: account.connected
                    ? () => _disconnect(account)
                    : null,
              ),
            ),
          const SizedBox(height: 20),
          Text(
            'Live brokers',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (liveBrokers.isEmpty)
            const _EmptyHint('No live brokers available.')
          else
            ...liveBrokers.map(
              (broker) => _BrokerTile(
                broker: broker,
                connected: connectedSlugs.contains(broker.slug),
                onConnect: () => _connect(state.accounts.first, broker),
              ),
            ),
          const SizedBox(height: 24),
          const Text(
            'Paper trading is always active as a fallback until a live broker '
            'is connected to an account.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({required this.account, this.onDisconnect});

  final BrokerAccount account;
  final VoidCallback? onDisconnect;

  @override
  Widget build(BuildContext context) {
    final color = account.connected
        ? Colors.green.shade700
        : Theme.of(context).colorScheme.outline;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          account.connected ? Icons.power : Icons.power_off,
          color: color,
        ),
        title: Text(account.name),
        subtitle: Text(
          account.connected
              ? '${account.broker?.name} · live'
              : 'Paper mode',
        ),
        trailing: account.connected
            ? IconButton(
                tooltip: 'Disconnect',
                onPressed: onDisconnect,
                icon: const Icon(Icons.link_off),
              )
            : null,
      ),
    );
  }
}

class _BrokerTile extends StatelessWidget {
  const _BrokerTile({
    required this.broker,
    required this.connected,
    required this.onConnect,
  });

  final Broker broker;
  final bool connected;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.trending_up),
        title: Text(broker.name),
        subtitle: Text(connected ? 'Connected to an account' : 'Not connected'),
        trailing: FilledButton.tonal(
          onPressed: connected ? null : onConnect,
          child: Text(connected ? 'Connected' : 'Connect'),
        ),
      ),
    );
  }
}

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
              onPressed: () => context.read<BrokerCubit>().load(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
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