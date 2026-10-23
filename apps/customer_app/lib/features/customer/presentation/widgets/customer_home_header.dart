import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

/// Greeting header for the Customer Home, composed from [AppPageHeader].
///
/// Ruling (a): the search icon lives in the shell AppBar (adjacent to
/// bell/avatar) — this header shows NO search icon. Greeting eyebrow + name
/// headline only; tapping search in the shell opens the same home search
/// sheet over the existing vehicles + bookings — no new routes, no new logic.
class CustomerHomeHeader extends StatelessWidget {
  final String firstName;
  final bool isNewCustomer;

  const CustomerHomeHeader({
    super.key,
    required this.firstName,
    required this.isNewCustomer,
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
      // No name yet: the page title itself is the greeting (no search icon
      // here — shell AppBar owns the single search path per ruling a).
      return AppPageHeader(title: welcome, subtitle: t.garBrandSub);
    }
    // Sentence-case greeting (C3): AppPageHeader upper-cases its eyebrow
    // slot, so the greeting renders as its own muted line above the name
    // headline instead of going through that slot.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        eyebrow,
        const SizedBox(height: AppSpacing.xs),
        AppPageHeader(title: name, subtitle: t.garBrandSub),
      ],
    );
  }
}
