import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Supervisor sign-in for the staff app, recomposed as a 2-step flow.
///
/// Step 1 collects the identifier (username/email, LTR-locked) behind
/// "Continue" (non-empty gate with the legacy copy); step 2 collects the
/// password ("Welcome back" + identifier recap) behind the sign-in CTA,
/// which runs the EXISTING [_login] byte-for-byte in behavior: same
/// username→email/phone split, same `loginWithPasswordProvider` call, same
/// `authenticate()` on success, same mapped-error [AppBanner] + retry, same
/// forgot `push('/forgot-password')`, same edit-clears-error. Typed values
/// live in the controllers, so the step-2 back arrow preserves them (UI
/// state only, no logic change).
///
/// Frozen-copy note (ARBs untouched): the step chrome reuses existing keys —
/// the step-2 CTA uses `forgotSignIn` ("Sign in"), the back label reuses the
/// generic staff "Back" key, and the progress label reuses the generic
/// `advisorIntakeWizardStepOf` pattern. All are flagged for dedicated
/// supervisor step keys in phase 9.
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
  int _step = 1;
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

  /// Step 1 submit: non-empty gate with the legacy copy, then advance.
  /// Values stay in the controllers; nothing calls the repository here.
  void _continueFromIdentifier() {
    if (_isLoading) return;
    final username = _usernameController.text.trim();
    if (username.isEmpty) {
      setState(() => _error = _emptyCredentialsCopy());
      return;
    }
    setState(() {
      _error = null;
      _step = 2;
    });
    // Focus on step entry: the scaffold renders the headline from a String
    // (header semantics built in), so focus lands on the step's field — the
    // entry point a screen reader announces next.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _passwordFocus.requestFocus();
    });
  }

  /// Step 2 back: controllers are untouched, so typed values survive.
  void _backToIdentifier() {
    if (_isLoading) return;
    setState(() {
      _error = null;
      _step = 1;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _identifierFocus.requestFocus();
    });
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
    final isFirst = _step == 1;

    return AppStepScaffold(
      step: _step,
      totalSteps: 2,
      backLabel:
          t?.advisorCheckInBack ??
          MaterialLocalizations.of(context).backButtonTooltip,
      onBack: isFirst || _isLoading ? null : _backToIdentifier,
      title:
          isFirst
              ? (t?.supervisorLoginTitle ?? a.supervisorLoginTitle)
              : a.loginWelcomeTitle,
      subtitle:
          isFirst ? (t?.supervisorLoginSubtitle ?? a.supervisorLoginSubtitle) : null,
      progressSemanticLabel: t?.advisorIntakeWizardStepOf(_step, 2),
      // The scaffold owns the sticky CTA but exposes no busy-label slot, so
      // the label swap happens here; AppPillButton still preserves width and
      // ignores taps while loading (single-submit, as before).
      ctaLabel:
          _isLoading
              ? a.authActionSigningIn
              : (isFirst ? a.loginActionContinue : a.forgotSignIn),
      onCta: isFirst ? _continueFromIdentifier : _login,
      isLoading: _isLoading,
      child: AutofillGroup(
        child: isFirst ? _identifierStep() : _passwordStep(),
      ),
    );
  }

  /// Step 1: identifier field (LTR-locked) + validation banner.
  Widget _identifierStep() {
    final t = StaffLocalizations.of(context);
    final a = SharedAuthL10n.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Form-level failure: live-region banner with a retry action
        // (the CTA below stays the primary path). Cleared on edit.
        if (_error != null) ...[
          AppBanner(
            kind: AppBannerKind.error,
            message: _error!,
            actionLabel: a.authActionRetry,
            onAction: _isLoading ? null : _continueFromIdentifier,
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
          onSubmitted: (_) => _continueFromIdentifier(),
        ),
      ],
    );
  }

  /// Step 2: identifier recap + password field (toggle) + forgot link.
  /// Login failures land here, above the password field.
  Widget _passwordStep() {
    final a = SharedAuthL10n.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
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
        // Identifier recap (caller-typed data, never a new copy key):
        // LTR-isolated so an email/username never reorders inside RTL
        // layouts; secondary text truncates instead of overflowing.
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            _usernameController.text.trim(),
            style: theme.textTheme.bodyMedium?.copyWith(
              color: scheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.start,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
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
    );
  }
}
