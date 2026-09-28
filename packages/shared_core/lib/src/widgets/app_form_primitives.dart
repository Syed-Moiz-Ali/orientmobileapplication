import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/app_card.dart';

/// Form Field wrapper with standard label, required indicator, helper, error, and child.
class AppFormField extends StatelessWidget {
  final String? label;
  final bool isRequired;
  final String? helperText;
  final String? errorText;
  final Widget? trailing;
  final Widget child;

  const AppFormField({
    super.key,
    this.label,
    this.isRequired = false,
    this.helperText,
    this.errorText,
    this.trailing,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || trailing != null) ...[
          Row(
            children: [
              if (label != null)
                Expanded(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          label!,
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      if (isRequired) ...[
                        const SizedBox(width: 4),
                        Text(
                          '*',
                          style: TextStyle(
                            color: AppColors.danger,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: AppDimensions.s6),
        ],
        child,
        if (errorText != null) ...[
          const SizedBox(height: 4),
          Text(
            errorText!,
            style: textTheme.bodySmall?.copyWith(
              color: AppColors.danger,
              fontWeight: FontWeight.w500,
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 4),
          Text(
            helperText!,
            style: textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

/// Composed form section container with a title, optional subtitle, and child inputs.
class AppFormSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  final EdgeInsetsGeometry padding;

  const AppFormSection({
    super.key,
    required this.title,
    this.subtitle,
    required this.child,
    this.padding = const EdgeInsets.only(bottom: AppDimensions.s24),
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    return Padding(
      padding: padding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: AppDimensions.s14),
          child,
        ],
      ),
    );
  }
}

/// Enclosed Form Panel grouping multiple inputs onto a clean white card.
class AppFormPanel extends StatelessWidget {
  final String? title;
  final String? subtitle;
  final Widget child;
  final Widget? footer;

  const AppFormPanel({
    super.key,
    this.title,
    this.subtitle,
    required this.child,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard.standard(
      padding: const EdgeInsets.all(AppDimensions.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.s16),
            Divider(height: 1, color: AppColors.borderDefault),
            const SizedBox(height: AppDimensions.s16),
          ],
          child,
          if (footer != null) ...[
            const SizedBox(height: AppDimensions.s20),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Clean Date/Time selector trigger button styled as a form input.
class AppDateSelectorShell extends StatelessWidget {
  final String? value;
  final String hint;
  final VoidCallback onTap;
  final IconData icon;
  final bool enabled;

  const AppDateSelectorShell({
    super.key,
    this.value,
    this.hint = 'Select date',
    required this.onTap,
    this.icon = Icons.calendar_today_rounded,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null && value!.isNotEmpty;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
        child: Container(
          constraints: const BoxConstraints(minHeight: AppDimensions.touchTarget),
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s16,
            vertical: AppDimensions.s12,
          ),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusInput),
            border: Border.all(color: AppColors.borderDefault),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppDimensions.iconSm,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  hasValue ? value! : hint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: hasValue
                        ? theme.colorScheme.onSurface
                        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
                    fontWeight: hasValue ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Clean media upload / attachment dropzone trigger.
class AppMediaUploadShell extends StatelessWidget {
  final String label;
  final String? helperText;
  final VoidCallback onTap;
  final IconData icon;
  final bool isLoading;

  const AppMediaUploadShell({
    super.key,
    this.label = 'Click to upload inspection photos or documents',
    this.helperText = 'Supports JPG, PNG, PDF up to 25MB',
    required this.onTap,
    this.icon = Icons.cloud_upload_outlined,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppDimensions.s24),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(
              color: AppColors.borderStrong,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                const SizedBox(
                  width: 32,
                  height: 32,
                  child: CircularProgressIndicator(strokeWidth: 2.5),
                )
              else ...[
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primarySubtle,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: colors.primary, size: 24),
                ),
                const SizedBox(height: AppDimensions.s12),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colors.onSurface,
                  ),
                ),
                if (helperText != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    helperText!,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
