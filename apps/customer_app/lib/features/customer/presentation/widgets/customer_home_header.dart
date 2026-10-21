import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

/// Greeting header for the Customer Home, composed from [AppPageHeader].
///
/// The greeting only — notifications live in the shell bar, so this row
/// never duplicates that chrome.
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

    if (name.isEmpty) {
      return AppPageHeader(title: welcome, subtitle: t.garBrandSub);
    }
    // Sentence-case greeting (C3): AppPageHeader upper-cases its eyebrow
    // slot, so the greeting renders as its own muted line above the name
    // headline instead of going through that slot.
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          welcome,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w800,
            fontSize: 11,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        AppPageHeader(title: name, subtitle: t.garBrandSub),
      ],
    );
  }
}
