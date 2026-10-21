import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Supervisor sign-in for the staff app, as ONE screen (scoped one-screen
/// rule: the frequent task stays on a single screen).
///
/// Identifier field + password field (toggle) + "Forgot password?" link
/// behind a single Continue/sign-in CTA, which runs the EXISTING [_login]
/// byte-for-byte in behavior: same username→email/phone split, same
/// `loginWithPasswordProvider` call, same `authenticate()` on success, same
/// mapped-error [AppBanner] + retry, same forgot `push('/forgot-password')`,
/// same edit-clears-error. Typed values live in the controllers (nothing is
/// ever cleared). A single [AutofillGroup] wraps both fields (username +
/// password hints together); focus order is identifier → password (`next`
/// moves focus, `done` on the password field submits).
///
/// Frozen-copy note (ARBs untouched): the CTA uses `forgotSignIn`
/// ("Sign in"), the progress label reuses the generic
/// `advisorIntakeWizardStepOf` pattern (1 of 1). Flagged for dedicated
/// supervisor keys in phase 9.
class SupervisorLoginView extends ConsumerStatefulWidget {
  const SupervisorLoginView({super.key});

  @override
  ConsumerState<SupervisorLoginView> createState() =>
      _SupervisorLoginViewState();
}

class _SupervisorLoginViewState extends ConsumerState<SupervisorLoginView> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _identifierFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _identifierFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  String _emptyCredentialsCopy() {
    final a = SharedAuthL10n.of(context);
    return StaffLocalizations.of(context)?.supervisorEnterCredentials ??
        a.supervisorEnterCredentials;
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;
    if (username.isEmpty || password.isEmpty) {
      setState(() => _error = _emptyCredentialsCopy());
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

    return AppStepScaffold(
      step: 1,
      totalSteps: 1,
      backLabel:
          t?.advisorCheckInBack ??
          MaterialLocalizations.of(context).backButtonTooltip,
      onBack: null,
      title: t?.supervisorLoginTitle ?? a.supervisorLoginTitle,
      subtitle: t?.supervisorLoginSubtitle ?? a.supervisorLoginSubtitle,
      progressSemanticLabel: t?.advisorIntakeWizardStepOf(1, 1),
      // The scaffold owns the sticky CTA but exposes no busy-label slot, so
      // the label swap happens here; AppPillButton still preserves width and
      // ignores taps while loading (single-submit, as before).
      ctaLabel: _isLoading ? a.authActionSigningIn : a.forgotSignIn,
      onCta: _login,
      isLoading: _isLoading,
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
              const SizedBox(height: AppSpacing.lg),
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
              focusNode: _identifierFocus,
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.md),
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
              focusNode: _passwordFocus,
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _login(),
            ),
            const SizedBox(height: AppSpacing.md),
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
