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
///
/// Phase-2c fixes (new `shared_auth` ARB fallback keys, listed for phase 9):
/// backend failures map through [mapAuthError] copy (never the raw
/// `e.message`), and every staff-copy lookup falls back to a shared_auth key
/// instead of a hardcoded English literal.
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
    final a = SharedAuthL10n.of(context);
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(
        () => _error =
            StaffLocalizations.of(context)?.supervisorEnterCredentials ??
            a.supervisorEnterCredentials,
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
        // Mapped copy only: expired/invalid/offline/server failures land on
        // their canonical line (with retry where it applies); the raw
        // transport message never reaches the screen.
        final display = mapAuthError(e, SharedAuthL10n.of(context));
        setState(() {
          _isLoading = false;
          _error = display.message;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context);
    final a = SharedAuthL10n.of(context);

    return AuthShell(
      title: t?.supervisorLoginTitle ?? a.supervisorLoginTitle,
      subtitle: t?.supervisorLoginSubtitle ?? a.supervisorLoginSubtitle,
      appName: t?.supervisorAppName ?? a.supervisorAppName,
      intendedUsers: t?.supervisorIntendedUsers ?? a.supervisorIntendedUsers,
      appPurpose: t?.supervisorAppPurpose ?? a.supervisorAppPurpose,
      securityNotice: t?.authSecurityNotice,
      child: AutofillGroup(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Form-level failure: live-region banner with a retry action
            // (the CTA below stays the primary path). Cleared on edit.
            if (_error != null) ...[
              AppBanner(
                kind: AppBannerKind.error,
                message: _error!,
                actionLabel: a.authActionRetry,
                onAction: _isLoading ? null : _login,
              ),
              const SizedBox(height: AppDimensions.s16),
            ],
            AppInputField(
              label: t?.supervisorUsernameLabel ?? a.supervisorUsernameLabel,
              hint: t?.supervisorUsernameHint ?? a.supervisorUsernameHint,
              controller: _usernameController,
              prefixIcon: Icons.person_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.username],
              forceLtr: true,
              enabled: !_isLoading,
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: AppDimensions.s16),
            AppInputField(
              label: a.loginFieldPassword,
              hint: a.loginFieldPasswordHint,
              controller: _passwordController,
              prefixIcon: Icons.lock_outline_rounded,
              obscureText: true,
              passwordToggle: true,
              showPasswordTooltip: a.authShowPassword,
              hidePasswordTooltip: a.authHidePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              forceLtr: true,
              enabled: !_isLoading,
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: AppDimensions.s24),
            AppPillButton.primary(
              label: a.loginActionContinue,
              busyLabel: a.authActionSigningIn,
              icon: Icons.arrow_forward_rounded,
              isLoading: _isLoading,
              onPressed: _login,
            ),
            const SizedBox(height: AppDimensions.s12),
            Center(
              child: AppTextButton(
                label: a.loginActionForgotPassword,
                onPressed: () => context.push('/forgot-password'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
