import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class AdvisorContactCard extends StatelessWidget {
  final String advisorName;
  final String advisorRole;
  final String phone;

  const AdvisorContactCard({
    super.key,
    // FIX (audit P0): fake identity + US phone number removed.
    this.advisorName = 'Service Advisor',
    this.advisorRole = 'Workshop Team',
    this.phone = '',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s14),
      borderRadius: AppDimensions.r20,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                advisorName.isNotEmpty ? advisorName.substring(0, 1) : 'A',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      advisorName,
                      style: textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified_rounded,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  advisorRole,
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Calling Service Advisor ($phone)...'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.phone_rounded,
                color: Color(0xFF10B981),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
