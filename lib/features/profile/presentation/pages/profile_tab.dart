import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/state/auth_cubit.dart';
import '../../../authentication/presentation/state/auth_state.dart';
import '../../../broker/domain/entities/broker.dart';
import '../../../broker/domain/entities/broker_account.dart';
import '../../../broker/presentation/pages/broker_connect_page.dart';
import '../../../broker/presentation/state/broker_cubit.dart';
import '../../../broker/presentation/state/broker_state.dart';
import '../../../trading/presentation/widgets/common_widgets.dart';
import 'change_password_dialog.dart';

/// Profile tab: user info, linked trading accounts, broker credentials
/// (Upstox / Zerodha / Angel / Groww / …), change password and sign out.
class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sign out?'),
        content: const Text('You will need to sign in again to trade.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sign out'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      context.read<AuthCubit>().logout();
    }
  }

  Future<void> _changePassword() async {
    final changed = await showDialog<bool>(
      context: context,
      builder: (_) => const ChangePasswordDialog(),
    );
    if (changed == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password changed. Please sign in again.'),
        ),
      );
      context.read<AuthCubit>().logout();
    }
  }

  void _showAbout() {
    showAboutDialog(
      context: context,
      applicationName: 'BankerTrader',
      applicationVersion: '1.0.0',
      applicationIcon: Image.asset('assets/images/logo.png', height: 48),
      children: const [
        Text(
          'Automated trading with per-user broker connections '
          '(Upstox, Zerodha, Angel, Groww and more). Paper trading is always '
          'active as a fallback.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthCubit, User?>(
      (c) => c.state is AuthAuthenticated ? (c.state as AuthAuthenticated).user : null,
    );

    return RefreshIndicator(
      onRefresh: () async {
        await context.read<BrokerCubit>().load();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        children: [
          if (user != null) _UserHeader(user: user),
          const SizedBox(height: 20),
          Text('Trading accounts', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const _AccountsSection(),
          const SizedBox(height: 20),
          Text('Broker credentials', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          const _BrokersSection(),
          const SizedBox(height: 20),
          Text('Account', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock_outline),
                  title: const Text('Change password'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _changePassword,
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: const Text('About'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _showAbout,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
              title: Text(
                'Sign out',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: _confirmSignOut,
            ),
          ),
        ],
      ),
    );
  }
}

class _UserHeader extends StatelessWidget {
  const _UserHeader({required this.user});

  final User user;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              child: Text(
                _initials(user.name),
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 2),
                  Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                  Text(
                    '@${user.username}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class _AccountsSection extends StatelessWidget {
  const _AccountsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrokerCubit, BrokerState>(
      builder: (context, state) {
        return switch (state) {
          BrokerInitial() || BrokerLoading() => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          BrokerError() => EmptyHint(state.message),
          BrokerLoaded() => _accounts(context, state.accounts),
        };
      },
    );
  }

  Widget _accounts(BuildContext context, List<BrokerAccount> accounts) {
    if (accounts.isEmpty) {
      return const EmptyHint('No trading accounts yet.');
    }
    return Column(
      children: accounts
          .map(
            (account) => Card(
              child: ListTile(
                leading: Icon(
                  account.connected ? Icons.account_balance_wallet : Icons.account_balance_wallet_outlined,
                  color: account.connected
                      ? Colors.green.shade700
                      : Theme.of(context).colorScheme.outline,
                ),
                title: Text(account.name),
                subtitle: Text(
                  account.connected
                      ? '${account.broker?.name ?? 'Live'} · live'
                      : 'Paper mode',
                ),
                trailing: Text(
                  account.connected ? 'Connected' : 'Not connected',
                  style: TextStyle(
                    color: account.connected
                        ? Colors.green.shade700
                        : Theme.of(context).colorScheme.outline,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => _openBrokerSettings(context),
              ),
            ),
          )
          .toList(growable: false),
    );
  }

  void _openBrokerSettings(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BrokerConnectPage()),
    );
    if (context.mounted) {
      context.read<BrokerCubit>().load();
    }
  }
}

class _BrokersSection extends StatelessWidget {
  const _BrokersSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrokerCubit, BrokerState>(
      builder: (context, state) {
        return switch (state) {
          BrokerInitial() || BrokerLoading() => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
          ),
          BrokerError() => EmptyHint(state.message),
          BrokerLoaded() => _brokers(context, state),
        };
      },
    );
  }

  Widget _brokers(BuildContext context, BrokerLoaded state) {
    final liveBrokers = state.brokers.where((b) => b.isLive).toList();
    final connectedSlugs = state.accounts
        .where((a) => a.connected)
        .map((a) => a.broker?.slug)
        .whereType<String>()
        .toSet();

    if (liveBrokers.isEmpty) {
      return const EmptyHint('No live brokers available.');
    }

    return Column(
      children: liveBrokers
          .map(
            (broker) => _BrokerRow(
              broker: broker,
              connected: connectedSlugs.contains(broker.slug),
              onTap: () => _openBrokerSettings(context),
            ),
          )
          .toList(growable: false),
    );
  }

  void _openBrokerSettings(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BrokerConnectPage()),
    );
    if (context.mounted) {
      context.read<BrokerCubit>().load();
    }
  }
}

class _BrokerRow extends StatelessWidget {
  const _BrokerRow({
    required this.broker,
    required this.connected,
    required this.onTap,
  });

  final Broker broker;
  final bool connected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.trending_up),
        title: Text(broker.name),
        subtitle: Text(connected ? 'Connected to an account' : 'Not connected'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              connected ? 'Connected' : 'Connect',
              style: TextStyle(
                color: connected
                    ? Colors.green.shade700
                    : Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
        onTap: onTap,
      ),
    );
  }
}