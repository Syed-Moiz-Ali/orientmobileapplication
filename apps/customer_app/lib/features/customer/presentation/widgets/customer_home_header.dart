import 'package:flutter/material.dart';

import 'package:customer_app/features/customer/presentation/support/customer_l10n.dart';

/// Compact personal header for the Customer Home surface.
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
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final name = firstName.trim();
    final welcome = isNewCustomer ? t.garWelcome : t.garHello;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (name.isNotEmpty)
          Text(
            welcome,
            style: theme.textTheme.labelMedium?.copyWith(
              color: colors.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        Text(
          name.isNotEmpty ? name : welcome,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.headlineSmall?.copyWith(
            color: colors.onSurface,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}
