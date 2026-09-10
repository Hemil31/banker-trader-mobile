import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../state/auth_cubit.dart';
import '../state/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.select<AuthCubit, String>((c) {
      final s = c.state;
      return s is AuthAuthenticated ? s.user.name : '';
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('BankerTrader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.account_balance_wallet,
              size: 72,
              color: Colors.teal,
            ),
            const SizedBox(height: 16),
            Text(
              'Welcome, $user',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            const Text('You are signed in.'),
          ],
        ),
      ),
    );
  }
}
