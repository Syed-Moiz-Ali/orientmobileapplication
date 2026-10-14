import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_semantic_colors.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// A single vertical-timeline event.
class AppTimelineEntry {
  final String title;
  final String? subtitle;
  final String? time;
  final StatusColorRole tone;
  final IconData? icon;

  const AppTimelineEntry({
    required this.title,
    this.subtitle,
    this.time,
    this.tone = StatusColorRole.neutral,
    this.icon,
  });
}

/// Vertical event timeline (Phase 01.2 foundation primitive).
///
/// Each entry renders a tone dot (resolved from the semantic status families —
/// never a hardcoded hex) joined by a hairline rail, with title / subtitle /
/// timestamp stacked at the reading-start side. RTL mirrors automatically via
/// directional layout.
class AppTimeline extends StatelessWidget {
  final List<AppTimelineEntry> entries;
  final bool showRail;

  const AppTimeline({
    super.key,
    required this.entries,
    this.showRail = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;

    return Semantics(
      container: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < entries.length; i++)
            _TimelineRow(
              entry: entries[i],
              isFirst: i == 0,
              isLast: i == entries.length - 1,
              showRail: showRail,
              status: semantic.status(entries[i].tone),
              outline: colors.outline,
              onSurface: colors.onSurface,
              onVariant: colors.onSurfaceVariant,
              textTheme: theme.textTheme,
            ),
        ],
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final AppTimelineEntry entry;
  final bool isFirst;
  final bool isLast;
  final bool showRail;
  final AppStatusColors status;
  final Color outline;
  final Color onSurface;
  final Color onVariant;
  final TextTheme textTheme;

  const _TimelineRow({
    required this.entry,
    required this.isFirst,
    required this.isLast,
    required this.showRail,
    required this.status,
    required this.outline,
    required this.onSurface,
    required this.onVariant,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Expanded(
                  child: Container(
                    width: 2,
                    color: !showRail || isFirst
                        ? Colors.transparent
                        : outline,
                  ),
                ),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: status.subtle,
                    shape: BoxShape.circle,
                    border: Border.all(color: status.border),
                  ),
                  child: Icon(
                    entry.icon ?? Icons.circle,
                    size: entry.icon == null ? 10 : 14,
                    color: status.base,
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    color:
                        !showRail || isLast ? Colors.transparent : outline,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: isLast ? 0 : AppDimensions.s16,
                top: AppDimensions.s4,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleSmall?.copyWith(
                            color: onSurface,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      if (entry.time != null) ...[
                        const SizedBox(width: AppDimensions.s8),
                        Text(
                          entry.time!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelSmall?.copyWith(
                            color: onVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  if (entry.subtitle != null) ...[
                    const SizedBox(height: AppDimensions.s4),
                    Text(
                      entry.subtitle!,
                      style: textTheme.bodySmall?.copyWith(color: onVariant),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
