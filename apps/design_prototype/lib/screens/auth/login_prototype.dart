// D5 · Login / Auth prototype.
//
// Mirrors the production shared_auth LoginView + AuthShell: compact single
// column, boxed card at tablet widths, navy identity panel split at >=900 px.
// Segmented password / one-time-code method, identifier auto-detect copy,
// password visibility toggle, inline invalid-credentials notice, OTP variant
// with 6 boxes + resend countdown. App identity (Staff / Customer / Owner /
// CRM) is switchable to validate per-app branding.
import 'dart:async';

import 'package:flutter/material.dart';

import '../../design/prototype_theme.dart';
import '../../design/provisional_tokens.dart';
import '../../fixtures/auth_fixtures.dart';
import '../../l10n/provisional_strings.dart';
import '../../widgets/proto_primitives.dart';

class LoginPrototype extends StatefulWidget {
  final String variant;

  const LoginPrototype({super.key, required this.variant});

  @override
  State<LoginPrototype> createState() => _LoginPrototypeState();
}

enum _AuthMode { password, code }

class _LoginPrototypeState extends State<LoginPrototype> {
  final _identifier = TextEditingController(text: authIdentifierFixture);
  final _password = TextEditingController();
  final _otp = TextEditingController();

  ProtoAuthApp _app = ProtoAuthApp.staff;
  _AuthMode _mode = _AuthMode.password;
  bool _otpSent = false;
  bool _obscure = true;
  bool _submitting = false;
  String _notice = '';
  Timer? _countdownTimer;
  int _countdown = 0;

  @override
  void initState() {
    super.initState();
    switch (widget.variant) {
      case 'invalid':
        _notice = ''; // set below with context-safe lookup on first build
        _password.text = 'wrong-password';
      case 'otp':
        _mode = _AuthMode.code;
        _otpSent = true;
        _countdown = 24;
        _otp.text = '5289';
        _startCountdown(from: 24);
      case 'loading':
        _submitting = true;
      case 'customer':
        _app = ProtoAuthApp.customer;
    }
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _identifier.dispose();
    _password.dispose();
    _otp.dispose();
    super.dispose();
  }

  void _startCountdown({required int from}) {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() {
        _countdown = _countdown <= 0 ? 0 : _countdown - 1;
        if (_countdown == 0) timer.cancel();
      });
    });
  }

  Future<void> _submitPassword() async {
    if (_submitting) return;
    setState(() {
      _submitting = true;
      _notice = '';
    });
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      if (widget.variant == 'invalid' || _password.text != 'orient') {
        _notice = context.s('login.notice.invalid');
        return;
      }
      _notice = '';
    });
    if (_notice.isEmpty) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.s('console.disclaimer'))));
    }
  }

  void _sendCode() {
    setState(() {
      _otpSent = true;
      _countdown = 30;
      _notice = '';
    });
    _startCountdown(from: 30);
  }

  Future<void> _verifyCode() async {
    if (_submitting) return;
    setState(() => _submitting = true);
    await Future<void>.delayed(const Duration(milliseconds: 700));
    if (!mounted) return;
    setState(() {
      _submitting = false;
      _notice = _otp.text.length == 6 ? '' : context.s('login.notice.invalid');
    });
    if (_otp.text.length == 6) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.s('console.disclaimer'))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    if (widget.variant == 'invalid' && _notice.isEmpty) {
      _notice = context.s('login.notice.invalid');
    }

    final formPane = _FormPane(
      app: _app,
      mode: _mode,
      otpSent: _otpSent,
      countdown: _countdown,
      obscure: _obscure,
      submitting: _submitting,
      notice: _notice,
      identifier: _identifier,
      password: _password,
      otp: _otp,
      onAppChanged: (app) => setState(() => _app = app),
      onModeChanged: (mode) => setState(() {
        _mode = mode;
        _notice = '';
        _otpSent = false;
      }),
      onToggleObscure: () => setState(() => _obscure = !_obscure),
      onSendCode: _sendCode,
      onSubmit: _mode == _AuthMode.password ? _submitPassword : _verifyCode,
    );

    return ColoredBox(
      color: p.canvas,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final split = constraints.maxWidth >= 900;
          if (split) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  flex: 5,
                  child: _IdentityPanel(app: _app),
                ),
                Expanded(
                  flex: 6,
                  child: _FormScroll(compact: false, boxed: false, child: formPane),
                ),
              ],
            );
          }
          final boxed = constraints.maxWidth >= 600;
          return _FormScroll(compact: !boxed, boxed: boxed, child: formPane);
        },
      ),
    );
  }
}

class _FormScroll extends StatelessWidget {
  final bool compact;
  final bool boxed;
  final Widget child;

  const _FormScroll({required this.compact, required this.boxed, required this.child});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final panel = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: boxed ? 440 : 480),
      child: child,
    );
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? ProtoSpace.s20 : ProtoSpace.s32,
        vertical: ProtoSpace.s32,
      ),
      child: Center(
        child: boxed
            ? Container(
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(ProtoRadius.panel),
                  border: Border.all(color: p.borderDefault),
                  boxShadow: ProtoElevation.card,
                ),
                padding: const EdgeInsets.all(ProtoSpace.s28),
                child: panel,
              )
            : panel,
      ),
    );
  }
}

class _IdentityPanel extends StatelessWidget {
  final ProtoAuthApp app;

  const _IdentityPanel({required this.app});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    return ColoredBox(
      color: p.navy,
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: ProtoSpace.s48, vertical: ProtoSpace.s40),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _BrandLockup(onDark: true),
                const SizedBox(height: ProtoSpace.s32),
                Text(
                  context.s('login.identity.headline'),
                  style: types.displaySmall.copyWith(color: p.textInverse, height: 1.3),
                ),
                const SizedBox(height: ProtoSpace.s12),
                Text(
                  context.s('login.identity.body'),
                  style: types.bodySmall.copyWith(color: p.onNavySecondary, height: 1.6),
                ),
                const SizedBox(height: ProtoSpace.s28),
                Container(
                  padding: const EdgeInsets.all(ProtoSpace.s16),
                  decoration: BoxDecoration(
                    color: p.navyRaised,
                    borderRadius: BorderRadius.circular(ProtoRadius.card),
                    border: Border.all(color: ProtoPalette.light.navyRaised),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.s(app.nameKey),
                        style: types.cardTitle.copyWith(color: p.textInverse),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        context.s(app.usersKey),
                        style: types.metadata.copyWith(
                          color: const Color(0xFF9DB4FF),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: ProtoSpace.s10),
                      Text(
                        context.s(app.purposeKey),
                        style: types.bodySmall.copyWith(color: p.onNavySecondary, height: 1.5),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: ProtoSpace.s28),
                _TrustPoint(icon: Icons.verified_user_outlined, label: context.s('login.trust.roles')),
                const SizedBox(height: ProtoSpace.s12),
                _TrustPoint(icon: Icons.sync_rounded, label: context.s('login.trust.sync')),
                const SizedBox(height: ProtoSpace.s12),
                _TrustPoint(icon: Icons.speed_rounded, label: context.s('login.trust.bays')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TrustPoint extends StatelessWidget {
  final IconData icon;
  final String label;

  const _TrustPoint({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: p.navyRaised,
            borderRadius: BorderRadius.circular(ProtoRadius.control),
          ),
          child: Icon(icon, size: 16, color: const Color(0xFF9DB4FF)),
        ),
        const SizedBox(width: ProtoSpace.s12),
        Expanded(
          child: Text(
            label,
            style: context.types.bodySmall
                .copyWith(color: p.onNavySecondary, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

class _FormPane extends StatelessWidget {
  final ProtoAuthApp app;
  final _AuthMode mode;
  final bool otpSent;
  final int countdown;
  final bool obscure;
  final bool submitting;
  final String notice;
  final TextEditingController identifier;
  final TextEditingController password;
  final TextEditingController otp;
  final ValueChanged<ProtoAuthApp> onAppChanged;
  final ValueChanged<_AuthMode> onModeChanged;
  final VoidCallback onToggleObscure;
  final VoidCallback onSendCode;
  final Future<void> Function() onSubmit;

  const _FormPane({
    required this.app,
    required this.mode,
    required this.otpSent,
    required this.countdown,
    required this.obscure,
    required this.submitting,
    required this.notice,
    required this.identifier,
    required this.password,
    required this.otp,
    required this.onAppChanged,
    required this.onModeChanged,
    required this.onToggleObscure,
    required this.onSendCode,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final types = context.types;
    final compact = MediaQuery.sizeOf(context).width < 900;
    final codeMode = mode == _AuthMode.code;

    final title = codeMode
        ? context.s('login.code.title')
        : context.s('login.welcome.title');
    final subtitle = codeMode
        ? (otpSent ? context.s('login.code.sentSubtitle') : context.s('login.code.subtitle'))
        : context.s('login.welcome.subtitle');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (compact) ...[
          _BrandLockup(onDark: false),
          const SizedBox(height: ProtoSpace.s24),
        ],
        _AppSwitcher(app: app, onChanged: onAppChanged),
        const SizedBox(height: ProtoSpace.s24),
        Text(title, style: types.pageTitle.copyWith(color: p.textPrimary, fontSize: 24)),
        const SizedBox(height: ProtoSpace.s6),
        Text(subtitle, style: types.bodySmall.copyWith(color: p.textMuted, height: 1.5)),
        const SizedBox(height: ProtoSpace.s20),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: p.surfaceSunken,
            borderRadius: BorderRadius.circular(ProtoRadius.control),
            border: Border.all(color: p.borderDefault),
          ),
          child: Row(
            children: [
              _methodTab(context, context.s('login.method.password'), mode == _AuthMode.password,
                  () => onModeChanged(_AuthMode.password)),
              _methodTab(context, context.s('login.method.code'), codeMode,
                  () => onModeChanged(_AuthMode.code)),
            ],
          ),
        ),
        const SizedBox(height: ProtoSpace.s20),
        if (notice.isNotEmpty) ...[
          ProtoInfoPanel(
            tone: ProtoTone.danger,
            icon: Icons.error_outline_rounded,
            text: notice,
          ),
          const SizedBox(height: ProtoSpace.s16),
        ],
        if (!codeMode || !otpSent) ...[
          ProtoField(
            label: context.s('login.field.identifier'),
            hint: context.s('login.field.identifierHint'),
            icon: Icons.alternate_email_rounded,
            controller: identifier,
            ltrContent: true,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: ProtoSpace.s16),
        ],
        if (!codeMode) ...[
          ProtoField(
            label: context.s('login.field.password'),
            hint: context.s('login.field.passwordHint'),
            icon: Icons.lock_outline_rounded,
            controller: password,
            obscureText: obscure,
            onToggleObscure: onToggleObscure,
            helperText: context.s('login.otpDemoHint'),
          ),
          const SizedBox(height: ProtoSpace.s4),
          Align(
            alignment: AlignmentDirectional.centerEnd,
            child: TextButton(
              onPressed: () {},
              child: Text(context.s('login.action.forgot')),
            ),
          ),
          const SizedBox(height: ProtoSpace.s8),
        ],
        if (codeMode) ...[
          if (!otpSent)
            Text(
              context.s('login.code.subtitle'),
              style: types.caption.copyWith(color: p.textMuted),
            )
          else ...[
            ProtoInfoPanel(
              tone: ProtoTone.info,
              icon: Icons.mark_email_read_outlined,
              text: context.s('login.notice.codeSent', {'target': identifier.text}),
            ),
            const SizedBox(height: ProtoSpace.s16),
            Text(
              context.s('login.field.otp'),
              style: types.label.copyWith(color: p.textSecondary),
            ),
            const SizedBox(height: ProtoSpace.s8),
            _OtpField(controller: otp, enabled: !submitting),
            const SizedBox(height: ProtoSpace.s16),
          ],
        ],
        const SizedBox(height: ProtoSpace.s8),
        SizedBox(
          height: 52,
          child: FilledButton(
            // Code mode before sending = "Send code"; after sending = "Verify".
            onPressed: submitting
                ? null
                : codeMode && !otpSent
                    ? onSendCode
                    : () => onSubmit(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (submitting) ...[
                  SizedBox(
                    width: 17,
                    height: 17,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.2,
                      valueColor: AlwaysStoppedAnimation(p.textInverse),
                    ),
                  ),
                  const SizedBox(width: ProtoSpace.s10),
                ] else ...[
                  Icon(codeMode ? Icons.verified_rounded : Icons.arrow_forward_rounded, size: 18),
                  const SizedBox(width: ProtoSpace.s8),
                ],
                Text(
                  codeMode
                      ? (otpSent ? context.s('login.action.verify') : context.s('login.action.sendCode'))
                      : context.s('login.action.continue'),
                  style: types.button.copyWith(color: p.textInverse, fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: ProtoSpace.s12),
        if (!codeMode)
          Center(
            child: TextButton.icon(
              onPressed: () => onModeChanged(_AuthMode.code),
              icon: const Icon(Icons.password_rounded, size: 17),
              label: Text(context.s('login.action.useCode')),
            ),
          ),
        if (codeMode && otpSent)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: ProtoSpace.s8,
            children: [
              TextButton(
                onPressed: () => onModeChanged(_AuthMode.password),
                child: Text(context.s('login.action.changeIdentifier')),
              ),
              TextButton(
                onPressed: countdown > 0 || submitting ? null : onSendCode,
                child: Text(
                  countdown > 0
                      ? context.s('login.action.resendIn', {'s': '$countdown'})
                      : context.s('login.action.resend'),
                ),
              ),
            ],
          ),
        if (codeMode && !otpSent)
          Center(
            child: TextButton.icon(
              onPressed: () => onModeChanged(_AuthMode.password),
              icon: const Icon(Icons.lock_outline_rounded, size: 16),
              label: Text(context.s('login.action.usePassword')),
            ),
          ),
        const SizedBox(height: ProtoSpace.s24),
        Row(
          children: [
            Icon(Icons.shield_outlined, size: 14, color: p.textMuted),
            const SizedBox(width: ProtoSpace.s6),
            Expanded(
              child: Text(
                context.s('login.badge'),
                style: types.caption.copyWith(color: p.textMuted, fontSize: 11.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _methodTab(BuildContext context, String label, bool selected, VoidCallback onTap) {
    final p = context.palette;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: ProtoMotion.fast,
          curve: ProtoMotion.enter,
          padding: const EdgeInsets.symmetric(vertical: ProtoSpace.s10),
          decoration: BoxDecoration(
            color: selected ? p.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(ProtoRadius.control - 2),
            border: Border.all(color: selected ? p.borderDefault : Colors.transparent),
            boxShadow: selected ? ProtoElevation.surface : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: context.types.label.copyWith(
              fontSize: 12.5,
              color: selected ? p.textPrimary : p.textMuted,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}

class _AppSwitcher extends StatelessWidget {
  final ProtoAuthApp app;
  final ValueChanged<ProtoAuthApp> onChanged;

  const _AppSwitcher({required this.app, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.s('login.appSwitcher'),
          style: context.types.metadata.copyWith(color: p.textDisabled, fontSize: 11),
        ),
        const SizedBox(height: ProtoSpace.s6),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final value in ProtoAuthApp.values) ...[
                ProtoFilterChip(
                  label: context.s(value.nameKey).replaceFirst('Orient ', '').replaceFirst('أورينت — ', ''),
                  selected: value == app,
                  onTap: () => onChanged(value),
                ),
                if (value != ProtoAuthApp.values.last) const SizedBox(width: ProtoSpace.s8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

/// Six-box OTP control (no external package): one hidden input drives six
/// rendered cells that flow start→end in both directions.
class _OtpField extends StatefulWidget {
  final TextEditingController controller;
  final bool enabled;

  const _OtpField({required this.controller, this.enabled = true});

  @override
  State<_OtpField> createState() => _OtpFieldState();
}

class _OtpFieldState extends State<_OtpField> {
  final _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _focus.dispose();
    super.dispose();
  }

  void _onChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final value = widget.controller.text;
    return Stack(
      children: [
        Opacity(opacity: 0, child: TextField(controller: widget.controller, focusNode: _focus, enabled: widget.enabled)),
        GestureDetector(
          onTap: () => _focus.requestFocus(),
          child: Row(
            children: [
              for (var i = 0; i < 6; i++) ...[
                Expanded(
                  child: Container(
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: p.surface,
                      borderRadius: BorderRadius.circular(ProtoRadius.input),
                      border: Border.all(
                        color: _focus.hasFocus && i == value.length.clamp(0, 5)
                            ? p.primary
                            : p.borderDefault,
                        width: _focus.hasFocus && i == value.length.clamp(0, 5) ? 1.6 : 1,
                      ),
                    ),
                    child: Text(
                      i < value.length ? value[i] : '',
                      style: context.types.cardTitle.copyWith(
                        color: p.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                if (i < 5) const SizedBox(width: ProtoSpace.s8),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _BrandLockup extends StatelessWidget {
  final bool onDark;

  const _BrandLockup({required this.onDark});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: onDark ? p.primary : p.primary,
            borderRadius: BorderRadius.circular(ProtoRadius.card),
          ),
          child: const Icon(Icons.build_rounded, color: Colors.white, size: 20),
        ),
        const SizedBox(width: ProtoSpace.s12),
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              context.s('dashboard.brand'),
              style: context.types.cardTitle.copyWith(
                color: onDark ? p.textInverse : p.textPrimary,
                letterSpacing: 1.6,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              context.s('dashboard.brandSub'),
              style: context.types.metadata.copyWith(
                color: onDark ? p.onNavySecondary : p.textMuted,
                letterSpacing: 1.0,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
