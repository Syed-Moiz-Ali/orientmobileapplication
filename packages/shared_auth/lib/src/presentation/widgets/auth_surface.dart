import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
import 'package:shared_auth/src/presentation/widgets/security_badge.dart';
import 'package:shared_core/shared_core.dart';

class AuthShell extends StatelessWidget {
  final Widget? top;
  final String title;
  final String subtitle;
  final Widget child;
  final Widget? footer;

  const AuthShell({
    super.key,
    this.top,
    required this.title,
    required this.subtitle,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: theme.brightness == Brightness.dark
            ? Brightness.light
            : Brightness.dark,
        systemNavigationBarColor: colorScheme.surface,
      ),
      child: Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final desktop = constraints.maxWidth >= 900;
              final form = _AuthFormPane(
                title: title,
                subtitle: subtitle,
                top: top,
                footer: footer,
                showCompactBrand: !desktop,
                child: child,
              );

              if (!desktop) return form;

              return Row(
                children: [
                  const Expanded(flex: 5, child: _AuthIdentityPanel()),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: colorScheme.outlineVariant,
                  ),
                  Expanded(flex: 6, child: form),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AuthIdentityPanel extends StatelessWidget {
  const _AuthIdentityPanel();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return ColoredBox(
      color: colors.surfaceContainerLow,
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.s40),
        child: Align(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const _AuthBrandMark(),
                const SizedBox(height: AppDimensions.s40),
                Text(
                  'One secure workspace for every workshop role.',
                  style: theme.textTheme.displaySmall?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                    height: 1.08,
                  ),
                ),
                const SizedBox(height: AppDimensions.s16),
                Text(
                  'Access bookings, job progress, approvals, and customer communication with the account assigned to you.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: AppDimensions.s32),
                const _AuthTrustPoint(
                  icon: Icons.verified_user_outlined,
                  label: 'Role-aware access',
                ),
                const SizedBox(height: AppDimensions.s12),
                const _AuthTrustPoint(
                  icon: Icons.sync_rounded,
                  label: 'Protected session continuity',
                ),
                const SizedBox(height: AppDimensions.s12),
                const _AuthTrustPoint(
                  icon: Icons.support_agent_rounded,
                  label: 'Workshop support when you need it',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthFormPane extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? top;
  final Widget child;
  final Widget? footer;
  final bool showCompactBrand;

  const _AuthFormPane({
    required this.title,
    required this.subtitle,
    required this.top,
    required this.child,
    required this.footer,
    required this.showCompactBrand,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final adaptive = context.adaptive;
    final horizontal = adaptive.pagePadding.horizontal / 2;

    return SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.symmetric(
        horizontal: horizontal,
        vertical: AppDimensions.s24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.sizeOf(context).height - AppDimensions.s48,
        ),
        child: Align(
          alignment: showCompactBrand ? Alignment.topCenter : Alignment.center,
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: adaptive.formMaxWidth),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (showCompactBrand) ...[
                  const _AuthBrandMark(),
                  const SizedBox(height: AppDimensions.s40),
                ],
                if (top != null) ...[
                  top!,
                  const SizedBox(height: AppDimensions.s20),
                ],
                Text(
                  'SECURE WORKSHOP ACCESS',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.9,
                  ),
                ),
                const SizedBox(height: AppDimensions.s8),
                Text(
                  title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    color: colors.onSurface,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: AppDimensions.s8),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: AppDimensions.s32),
                child,
                const SizedBox(height: AppDimensions.s24),
                footer ?? const SecurityBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthBrandMark extends StatelessWidget {
  const _AuthBrandMark();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: colors.primaryContainer,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
          ),
          child: Icon(
            Icons.build_rounded,
            color: colors.onPrimaryContainer,
            size: 22,
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ORIENT',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
            Text(
              'WORKSHOP',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _AuthTrustPoint extends StatelessWidget {
  final IconData icon;
  final String label;

  const _AuthTrustPoint({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 20, color: colors.primary),
        const SizedBox(width: AppDimensions.s12),
        Text(label, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class AuthTextField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AuthTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.errorText,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<AuthTextField> {
  late bool _hidden;

  @override
  void initState() {
    super.initState();
    _hidden = widget.obscureText;
  }

  @override
  void didUpdateWidget(AuthTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _hidden = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    return TextField(
      controller: widget.controller,
      keyboardType: widget.keyboardType,
      obscureText: _hidden,
      cursorColor: colorScheme.primary,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.w600,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        errorText: widget.errorText,
        prefixIcon: Icon(
          widget.icon,
          size: 20,
          color: colorScheme.onSurfaceVariant,
        ),
        suffixIcon: widget.obscureText
            ? IconButton(
                onPressed: () => setState(() => _hidden = !_hidden),
                icon: Icon(
                  _hidden
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: colorScheme.onSurfaceVariant,
                ),
                tooltip: _hidden ? 'Show password' : 'Hide password',
              )
            : null,
      ),
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}

class AuthPrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final IconData? icon;

  const AuthPrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final disabled = onPressed == null || isLoading;

    return SizedBox(
      width: double.infinity,
      height: AppDimensions.touchTarget + AppDimensions.s4,
      child: FilledButton(
        onPressed: disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          disabledBackgroundColor: colorScheme.surfaceContainerHighest,
          disabledForegroundColor: colorScheme.onSurfaceVariant,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  valueColor: AlwaysStoppedAnimation(colorScheme.onPrimary),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: colorScheme.onPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: AppDimensions.s8),
                    Icon(icon, size: 18, color: colorScheme.onPrimary),
                  ],
                ],
              ),
      ),
    );
  }
}

class AuthLinkButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;

  const AuthLinkButton({
    super.key,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: colorScheme.primary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s8,
          vertical: AppDimensions.s10,
        ),
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class AuthOtpField extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;
  final String? errorText;

  const AuthOtpField({
    super.key,
    required this.onChanged,
    this.onSubmitted,
    this.errorText,
  });

  @override
  State<AuthOtpField> createState() => _AuthOtpFieldState();
}

class _AuthOtpFieldState extends State<AuthOtpField> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    PinTheme pinTheme({
      required double width,
      required Color borderColor,
      required Color fillColor,
      double borderWidth = 1,
    }) {
      return PinTheme(
        width: width,
        height: 56,
        textStyle: theme.textTheme.titleMedium?.copyWith(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w900,
        ),
        decoration: BoxDecoration(
          color: fillColor,
          borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
          border: Border.all(color: borderColor, width: borderWidth),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification Code',
          style: theme.textTheme.labelMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.s10),
        LayoutBuilder(
          builder: (context, constraints) {
            final fieldWidth = ((constraints.maxWidth - 40) / 6)
                .clamp(42.0, 54.0)
                .toDouble();
            final defaultTheme = pinTheme(
              width: fieldWidth,
              borderColor: colorScheme.outlineVariant,
              fillColor: colorScheme.surfaceContainerLow,
            );

            return Pinput(
              controller: _controller,
              length: 6,
              autofocus: true,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              defaultPinTheme: defaultTheme,
              focusedPinTheme: pinTheme(
                width: fieldWidth,
                borderColor: colorScheme.primary,
                fillColor: colorScheme.surface,
                borderWidth: 1.8,
              ),
              submittedPinTheme: pinTheme(
                width: fieldWidth,
                borderColor: colorScheme.primary.withValues(alpha: 0.5),
                fillColor: colorScheme.surfaceContainerLow,
              ),
              errorPinTheme: pinTheme(
                width: fieldWidth,
                borderColor: colorScheme.error,
                fillColor: colorScheme.errorContainer.withValues(alpha: 0.2),
                borderWidth: 1.5,
              ),
              forceErrorState: hasError,
              onChanged: widget.onChanged,
              onCompleted: widget.onSubmitted,
            );
          },
        ),
        if (hasError) ...[
          const SizedBox(height: AppDimensions.s8),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.error,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}
