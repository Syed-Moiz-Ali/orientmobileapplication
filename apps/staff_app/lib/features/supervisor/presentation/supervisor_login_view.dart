import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

class SupervisorLoginView extends ConsumerStatefulWidget {
  const SupervisorLoginView({super.key});

  @override
  ConsumerState<SupervisorLoginView> createState() =>
      _SupervisorLoginViewState();
}

class _SupervisorLoginViewState extends ConsumerState<SupervisorLoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter username and password');
      return;
    }
    setState(() {
      _isLoading = true;
      _error = null;
    });

    final login = ref.read(loginWithPasswordProvider);
    final isEmail = username.contains('@');
    final result = await login(
      isEmail ? username : '',
      isEmail ? '' : username,
      password,
    );

    if (!mounted) return;
    result.when(
      success: (auth) async {
        await ref
            .read(authNotifierProvider.notifier)
            .authenticate(
              auth.role,
              auth.token,
              refreshToken: auth.refreshToken,
            );
      },
      failure: (e) {
        setState(() {
          _isLoading = false;
          _error = e.message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: 'Supervisor access',
      subtitle: 'Sign in with your workshop account.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AuthTextField(
            controller: _usernameController,
            label: 'Username or email',
            hint: 'Enter your username or email',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            errorText: _error,
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: AppDimensions.s20),
          AuthTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Enter your password',
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _login(),
          ),
          const SizedBox(height: AppDimensions.s24),
          AuthPrimaryButton(
            label: 'Continue',
            icon: Icons.arrow_forward_rounded,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _login,
          ),
          const SizedBox(height: AppDimensions.s16),
          Center(
            child: AuthLinkButton(
              label: 'Forgot password?',
              onPressed: () => context.push('/forgot-password'),
            ),
          ),
        ],
      ),
    );
  }
}
