import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

/// Greeting header for the Customer Home, composed from [AppPageHeader].
///
/// Top row: the greeting eyebrow with the ONE search icon at the end side
/// (U1/U9 — same placement as the advisor home header; the bell and avatar
/// live in the shell bar, so this row never duplicates that chrome).
/// Tapping search opens the full-screen search sheet over the home's
/// existing vehicles + bookings — no new routes, no new logic.
class CustomerHomeHeader extends StatelessWidget {
  final String firstName;
  final bool isNewCustomer;
  final VoidCallback onSearch;

  const CustomerHomeHeader({
    super.key,
    required this.firstName,
    required this.isNewCustomer,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.cx;
    final name = firstName.trim();
    final welcome = isNewCustomer ? t.garWelcome : t.garHello;

    final Widget eyebrow = Text(
      welcome,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w800,
        fontSize: 11,
      ),
    );

    if (name.isEmpty) {
      // No name yet: the page title itself is the greeting, so the search
      // icon docks beside it instead of adding a second greeting line.
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AppPageHeader(title: welcome, subtitle: t.garBrandSub),
          ),
          const SizedBox(width: AppSpacing.sm),
          AppIconButton(
            icon: Icons.search_rounded,
            onPressed: () {
              HapticFeedback.selectionClick();
              onSearch();
            },
            tooltip: t.garSearchTitle,
          ),
        ],
      );
    }
    // Sentence-case greeting (C3): AppPageHeader upper-cases its eyebrow
    // slot, so the greeting renders as its own muted line above the name
    // headline instead of going through that slot.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: eyebrow),
            AppIconButton(
              icon: Icons.search_rounded,
              onPressed: () {
                HapticFeedback.selectionClick();
                onSearch();
              },
              tooltip: t.garSearchTitle,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        AppPageHeader(title: name, subtitle: t.garBrandSub),
      ],
    );
  }
}
