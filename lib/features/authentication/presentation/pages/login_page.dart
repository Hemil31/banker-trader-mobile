import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../state/auth_cubit.dart';
import '../state/auth_state.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(text: 'dev');
  final _passwordController = TextEditingController(text: 'devpassword');
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Temp dev credentials prefilled so the app can be opened to the shell
    // with a single tap; replace with real auth when available.
    _identifierController.text = 'dev';
    _passwordController.text = 'devpassword';
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthCubit>().login(
      _identifierController.text.trim(),
      _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (context, state) {
        final isLoading = state is AuthLoading;
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const _LoginHero(),
                      const SizedBox(height: 32),
                      TextFormField(
                        controller: _identifierController,
                        autofillHints: const [AutofillHints.username],
                        decoration: const InputDecoration(
                          labelText: 'Email or username',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Enter your email or username'
                            : null,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: AppSpace.lg),
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        autofillHints: const [AutofillHints.password],
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: () => setState(
                              () => _obscurePassword = !_obscurePassword,
                            ),
                          ),
                        ),
                        validator: (value) => value == null || value.isEmpty
                            ? 'Enter your password'
                            : null,
                        onFieldSubmitted: (_) => _submit(),
                      ),
                      const SizedBox(height: AppSpace.xl),
                      FilledButton(
                        onPressed: isLoading ? null : _submit,
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Sign in'),
                      ),
                      const SizedBox(height: AppSpace.lg),
                      Center(
                        child: PopupMenuButton<String>(
                          tooltip: 'Fill test credentials',
                          onSelected: (value) {
                            final split = value.split('/');
                            _identifierController.text = split.first;
                            _passwordController.text = split.last;
                            setState(() => _obscurePassword = true);
                          },
                          itemBuilder: (context) => const [
                            PopupMenuItem(
                              value: 'dev/devpassword',
                              child: Text('dev / devpassword'),
                            ),
                            PopupMenuItem(
                              value: 'admin/adminpassword',
                              child: Text('admin / adminpassword'),
                            ),
                          ],
                          child: Text(
                            'Dev: dev/devpassword · Admin: admin/adminpassword',
                            textAlign: TextAlign.center,
                            style: AppFonts.body(
                              size: 11.5,
                              color: AppColors.textMuted,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _LoginHero extends StatelessWidget {
  const _LoginHero();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.all(14),
          child: Image.asset(
            'assets/images/logo.png',
            errorBuilder: (_, _, _) => const Icon(
              Icons.trending_up_rounded,
              color: AppColors.accent,
              size: 32,
            ),
          ),
        ),
        const SizedBox(height: AppSpace.lg),
        Text(
          'BankerTrader',
          style: AppFonts.body(
            size: 12,
            weight: FontWeight.w700,
            color: AppColors.accent,
          ).copyWith(letterSpacing: 0.4),
        ),
        const SizedBox(height: 4),
        Text('Welcome back', style: AppFonts.display(size: 24)),
        const SizedBox(height: 4),
        Text(
          'Sign in to your paper trading desk.',
          style: AppFonts.body(size: 13.5, color: AppColors.textMuted),
        ),
      ],
    );
  }
}
