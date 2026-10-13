import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Supervisor sign-in for the staff app.
///
/// Rebuilt on the shared auth components so staff has a single auth language;
/// the username/password + continue + forgot behavior is preserved exactly.
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
      setState(
        () => _error =
            StaffLocalizations.of(context)?.supervisorEnterCredentials ??
            'Enter username and password',
      );
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
    final t = StaffLocalizations.of(context);
    final a = SharedAuthL10n.of(context);

    return AuthShell(
      title: t?.supervisorLoginTitle ?? 'Supervisor access',
      subtitle:
          t?.supervisorLoginSubtitle ??
          'Sign in to manage bookings, assignments, QC, and workshop operations.',
      appName: t?.supervisorAppName ?? 'Orient Supervisor Console',
      intendedUsers: t?.supervisorIntendedUsers ?? 'For workshop supervisors',
      appPurpose:
          t?.supervisorAppPurpose ??
          'Review incoming bookings, assign advisors and technicians, monitor jobs, and complete quality checks.',
      securityNotice: t?.authSecurityNotice,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthNoticeSlot(message: _error),
          AuthTextField(
            controller: _usernameController,
            label: t?.supervisorUsernameLabel ?? 'Username or email',
            hint: t?.supervisorUsernameHint ?? 'Enter your username or email',
            icon: Icons.person_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.username],
            textDirection: TextDirection.ltr,
            enabled: !_isLoading,
            onChanged: (_) => setState(() => _error = null),
          ),
          const SizedBox(height: AppDimensions.s16),
          AuthTextField(
            controller: _passwordController,
            label: a.loginFieldPassword,
            hint: a.loginFieldPasswordHint,
            icon: Icons.lock_outline_rounded,
            obscureText: true,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.password],
            enabled: !_isLoading,
            onChanged: (_) => setState(() => _error = null),
            onSubmitted: (_) => _login(),
          ),
          const SizedBox(height: AppDimensions.s24),
          AuthPrimaryButton(
            label: a.loginActionContinue,
            icon: Icons.arrow_forward_rounded,
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _login,
          ),
          const SizedBox(height: AppDimensions.s12),
          Center(
            child: AuthLinkButton(
              label: a.loginActionForgotPassword,
              onPressed: () => context.push('/forgot-password'),
            ),
          ),
        ],
      ),
    );
  }
}
