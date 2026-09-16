part of 'customer_profile_tab.dart';

/// Profile's grouped-surface presentation primitives.
///
/// They are a part of the Profile library so they stay private to it: no
/// other feature can reach them, and they are not a new public API.

class _SectionLabel extends StatelessWidget {
  final String label;

  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(left: AppDimensions.s4),
      child: Text(
        label,
        style: theme.textTheme.labelMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

/// One grouped surface, rows separated by dividers.
class _Group extends StatelessWidget {
  final List<Widget> children;

  const _Group({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index < children.length - 1)
              Divider(height: 1, color: colors.outlineVariant),
          ],
        ],
      ),
    );
  }
}

/// A compact, tappable account action.
///
/// Every instance is wired to a real destination — the row owns no state and
/// has no no-op fallback, so it cannot be rendered without an effect.
class _ActionRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? trailingText;
  final VoidCallback onTap;

  const _ActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle = '',
    this.trailingText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final trailing = trailingText ?? '';

    return Semantics(
      button: true,
      label: subtitle.isEmpty ? title : '$title. $subtitle',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s16,
            vertical: AppDimensions.s12,
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: AppDimensions.iconMd,
                color: colors.onSurfaceVariant,
              ),
              const SizedBox(width: AppDimensions.s14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing.isNotEmpty) ...[
                const SizedBox(width: AppDimensions.s8),
                Text(
                  trailing,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
              const SizedBox(width: AppDimensions.s6),
              Icon(
                Icons.chevron_right_rounded,
                size: AppDimensions.iconMd,
                color: colors.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A read-only account fact.
///
/// It is deliberately not tappable and carries no chevron: unlike an action
/// row, there is nothing behind it to open.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final EdgeInsetsGeometry? padding;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Padding(
        padding:
            padding ??
            const EdgeInsets.symmetric(
              horizontal: AppDimensions.s16,
              vertical: AppDimensions.s12,
            ),
        child: Row(
          children: [
            Icon(
              icon,
              size: AppDimensions.iconMd,
              color: colors.onSurfaceVariant,
            ),
            const SizedBox(width: AppDimensions.s14),
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Text(
                value,
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Session control: restrained, never the page's primary positive action.
class _SignOutButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _SignOutButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.logout_rounded, size: 18),
      label: const Text('Sign out'),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(AppDimensions.touchTarget),
        foregroundColor: colors.error,
        side: BorderSide(color: colors.error.withValues(alpha: 0.35)),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
        ),
      ),
    );
  }
}
