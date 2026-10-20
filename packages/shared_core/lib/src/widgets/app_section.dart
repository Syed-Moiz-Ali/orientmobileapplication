import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_spacing.dart';
import 'package:shared_core/src/widgets/app_text_button.dart';

/// Spec-C8 section wrapper (phase-1c-i).
///
/// `titleMedium` heading, optional ghost "See all" action, optional
/// subtitle, 12 px gap to content (spec C4).
///
/// ```dart
/// AppSection(
///   title: 'Recent activity',
///   subtitle: 'Last 7 days',
///   seeAllLabel: 'See all',
///   onSeeAll: showAll,
///   child: AppSurfaceCard(child: Text('...')),
/// )
/// ```
///
/// - Tokens only, caller-supplied text, Directional-safe (start-aligned).
/// - Heading exposed as a Semantics header; the see-all action is a real
///   button with a 48 dp target via [AppTextButton].
/// - Wraps at text scale 1.3x (title + action share a Flexible row).
class AppSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? seeAllLabel;
  final VoidCallback? onSeeAll;
  final Widget child;

  const AppSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.seeAllLabel,
    this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Semantics(
                header: true,
                child: Text(title, style: textTheme.titleMedium),
              ),
            ),
            if (seeAllLabel != null && onSeeAll != null)
              AppTextButton(label: seeAllLabel!, onPressed: onSeeAll),
          ],
        ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: AppSpacing.xxs),
            child: Text(
              subtitle!,
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.md),
        child,
      ],
    );
  }
}
