import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

/// One compact label/value pair.
class CustomerStatusDetail {
  final IconData icon;
  final String label;
  final String value;

  const CustomerStatusDetail({
    required this.icon,
    required this.label,
    required this.value,
  });
}

/// Grouped secondary information for the Status screen.
///
/// Deliberately uses a quiet label/value language instead of turning every
/// reference into a badge, and renders nothing when there is no real data.
class CustomerStatusDetails extends StatelessWidget {
  final List<CustomerStatusDetail> rows;
  final String title;

  const CustomerStatusDetails({
    super.key,
    required this.rows,
    this.title = 'Service details',
  });

  @override
  Widget build(BuildContext context) {
    if (rows.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: title),
        DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(color: colors.outlineVariant),
          ),
          child: Column(
            children: [
              for (var index = 0; index < rows.length; index++) ...[
                _DetailRow(detail: rows[index]),
                if (index < rows.length - 1)
                  Divider(height: 1, color: colors.outlineVariant),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final CustomerStatusDetail detail;

  const _DetailRow({required this.detail});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Semantics(
      excludeSemantics: true,
      label: '${detail.label}, ${detail.value}',
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s14,
          vertical: AppDimensions.s12,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                detail.icon,
                size: 18,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    detail.label,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail.value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colors.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
