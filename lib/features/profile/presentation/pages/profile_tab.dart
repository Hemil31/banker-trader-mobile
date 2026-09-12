import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../authentication/domain/entities/user.dart';
import '../../../authentication/presentation/state/auth_cubit.dart';
import '../../../authentication/presentation/state/auth_state.dart';
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
      color: AppColors.accent,
      onRefresh: () async {
        await context.read<BrokerCubit>().load();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppSpace.lg),
        children: [
          if (user != null) _UserHeader(user: user),
          const SizedBox(height: AppSpace.xl),
          SectionLabel('Connect trading account'),
          const _TradingAccountSection(),
          const SizedBox(height: AppSpace.lg),
          SectionLabel('Account'),
          Card(
            child: Column(
              children: [
                _SettingsRow(
                  icon: Icons.lock_outline,
                  label: 'Change password',
                  onTap: _changePassword,
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                _SettingsRow(
                  icon: Icons.info_outline,
                  label: 'About',
                  onTap: _showAbout,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpace.lg),
          Card(
            child: _SettingsRow(
              icon: Icons.logout,
              label: 'Sign out',
              color: AppColors.negative,
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
        padding: const EdgeInsets.all(AppSpace.lg),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Text(
                _initials(user.name),
                style: AppFonts.display(size: 18, color: AppColors.accent),
              ),
            ),
            const SizedBox(width: AppSpace.lg),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.name, style: AppFonts.body(size: 15, weight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(user.email, style: AppFonts.body(size: 12, color: AppColors.textMuted)),
                  Text(
                    '@${user.username}',
                    style: AppFonts.body(size: 12, color: AppColors.textMuted),
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

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.lg),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpace.lg,
          vertical: AppSpace.md,
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color ?? AppColors.textMuted),
            const SizedBox(width: AppSpace.md),
            Expanded(
              child: Text(
                label,
                style: AppFonts.body(
                  size: 13.5,
                  weight: FontWeight.w600,
                  color: color ?? AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20),
          ],
        ),
      ),
    );
  }
}

/// Single entry point for trading accounts + broker connections. Tapping it
/// opens [BrokerConnectPage], where each account has its own broker dropdown
/// and connect/disconnect actions — this row is just an at-a-glance summary.
class _TradingAccountSection extends StatelessWidget {
  const _TradingAccountSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BrokerCubit, BrokerState>(
      builder: (context, state) {
        return switch (state) {
          BrokerInitial() || BrokerLoading() => const Center(
            child: Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(color: AppColors.accent),
            ),
          ),
          BrokerError() => EmptyHint(state.message),
          BrokerLoaded() => _summary(context, state.accounts),
        };
      },
    );
  }

  Widget _summary(BuildContext context, List<BrokerAccount> accounts) {
    if (accounts.isEmpty) {
      return const EmptyHint(
        'No trading accounts yet.',
        icon: Icons.account_balance_wallet_outlined,
      );
    }

    final connected = accounts.where((a) => a.connected).toList();
    final title = accounts.length == 1 ? accounts.first.name : 'Trading accounts';
    final String caption;
    if (accounts.length == 1) {
      caption = connected.isEmpty
          ? 'Paper mode'
          : '${connected.first.broker?.name ?? 'Live'} · live';
    } else {
      caption = '${connected.length} of ${accounts.length} connected';
    }

    return RowCard(
      title: title,
      caption: caption,
      trailing: connected.isEmpty
          ? PillBadge.neutral('Not connected', dense: true)
          : PillBadge.positive('Connected', dense: true),
      onTap: () => _openBrokerSettings(context),
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
