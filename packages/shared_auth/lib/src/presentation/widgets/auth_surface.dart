import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pinput/pinput.dart';
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
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: AppColors.bg,
      ),
      child: Scaffold(
        backgroundColor: AppColors.bg,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final adaptive = AppResponsive.specFor(
                context,
                constraints: constraints,
              );
              final horizontal = adaptive.pagePadding.horizontal / 2;
              final topInset = adaptive.pagePadding.top;
              final contentWidth = adaptive.formMaxWidth;

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  horizontal,
                  topInset,
                  horizontal,
                  AppDimensions.s24,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight:
                        constraints.maxHeight - topInset - AppDimensions.s24,
                  ),
                  child: Align(
                    alignment: adaptive.focusedFlowAlignment,
                    child: SizedBox(
                      width: contentWidth,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (top != null) ...[
                            top!,
                            SizedBox(height: adaptive.itemSpacing),
                          ],
                          Container(
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(
                                AppDimensions.rPill,
                              ),
                            ),
                          ),
                          SizedBox(height: adaptive.itemSpacing),
                          ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: contentWidth),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.displayMedium
                                      ?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w800,
                                        height: 1.08,
                                      ),
                                ),
                                const SizedBox(height: AppDimensions.s6),
                                Text(
                                  subtitle,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: AppColors.text3,
                                    height: 1.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: adaptive.sectionSpacing),
                          SizedBox(
                            width: double.infinity,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: contentWidth,
                              ),
                              child: child,
                            ),
                          ),
                          if (footer != null) ...[
                            const SizedBox(height: AppDimensions.s20),
                            footer!,
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
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
    final hasError = widget.errorText != null && widget.errorText!.isNotEmpty;

    return Focus(
      onFocusChange: (_) => setState(() {}),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.text3,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.s4),
          TextField(
            controller: widget.controller,
            keyboardType: widget.keyboardType,
            obscureText: _hidden,
            cursorColor: colorScheme.primary,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface,
              fontSize: 17,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: widget.hint,
              suffixIcon: widget.obscureText
                  ? IconButton(
                      onPressed: () => setState(() => _hidden = !_hidden),
                      icon: Icon(
                        _hidden
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 20,
                      ),
                      tooltip: _hidden ? 'Show password' : 'Hide password',
                    )
                  : null,
              filled: false,
              contentPadding: const EdgeInsets.symmetric(
                vertical: AppDimensions.s12,
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? colorScheme.error : AppColors.borderMd,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? colorScheme.error : AppColors.borderMd,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: hasError ? colorScheme.error : colorScheme.primary,
                  width: 1.4,
                ),
              ),
              hintStyle: theme.textTheme.bodyLarge?.copyWith(
                color: AppColors.text4,
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            onChanged: widget.onChanged,
            onSubmitted: widget.onSubmitted,
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
      ),
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
      height: 52,
      child: FilledButton(
        onPressed: disabled ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.border,
          disabledForegroundColor: AppColors.text3,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.r10),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (icon != null) ...[
                    const SizedBox(width: AppDimensions.s8),
                    Icon(icon, size: 18),
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
          vertical: AppDimensions.s12,
        ),
        minimumSize: const Size(48, 48),
        tapTargetSize: MaterialTapTargetSize.padded,
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(
          color: colorScheme.primary,
          fontWeight: FontWeight.w700,
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
      double borderWidth = 1,
    }) {
      return PinTheme(
        width: width,
        height: 54,
        textStyle: theme.textTheme.titleMedium?.copyWith(
          color: AppColors.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w800,
        ),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: borderColor, width: borderWidth),
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Verification code',
          style: theme.textTheme.titleSmall?.copyWith(
            color: AppColors.text3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppDimensions.s10),
        LayoutBuilder(
          builder: (context, constraints) {
            final fieldWidth = ((constraints.maxWidth - 40) / 6)
                .clamp(42.0, 52.0)
                .toDouble();
            final defaultTheme = pinTheme(
              width: fieldWidth,
              borderColor: AppColors.borderMd,
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
                borderWidth: 1.5,
              ),
              submittedPinTheme: pinTheme(
                width: fieldWidth,
                borderColor: colorScheme.primary,
              ),
              errorPinTheme: pinTheme(
                width: fieldWidth,
                borderColor: colorScheme.error,
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
