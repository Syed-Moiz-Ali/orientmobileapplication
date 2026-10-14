import 'package:flutter/material.dart';
import 'package:shared_core/l10n/gen/shared_core_localizations.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';

/// The truthful sync state of a locally-created or locally-modified record.
enum SyncChipState {
  /// A local change that has not reached the server yet.
  notSent,

  /// A local change queued for the next sync pass.
  queued,

  /// A local change whose sync attempt failed.
  failed,

  /// A local change that has been synchronized.
  synced,
}

/// Compact, localized chip that communicates offline/queued/failed sync state
/// for a record or action. State is always encoded by **icon + text + color**
/// (never color alone), per spec §2.2 rule 3 and V14.
///
/// Used by the staff and customer offline-sync UX; the label is read from
/// `SharedCoreLocalizations` but can be overridden with [label] when a caller
/// needs more specific copy.
class PendingSyncChip extends StatelessWidget {
  final SyncChipState state;
  final String? label;
  final bool compact;

  const PendingSyncChip({
    super.key,
    required this.state,
    this.label,
    this.compact = false,
  });

  ({Color fg, Color bg, Color border, IconData icon}) _resolve(
    BuildContext context,
  ) {
    final semantic = context.semanticColors;
    switch (state) {
      case SyncChipState.notSent:
        final role = semantic.syncNotSent;
        return (
          fg: role.ink,
          bg: role.subtle,
          border: role.border,
          icon: Icons.cloud_off_rounded,
        );
      case SyncChipState.queued:
        final role = semantic.syncQueued;
        return (
          fg: role.ink,
          bg: role.subtle,
          border: role.border,
          icon: Icons.schedule_send_rounded,
        );
      case SyncChipState.failed:
        final role = semantic.syncFailed;
        return (
          fg: role.ink,
          bg: role.subtle,
          border: role.border,
          icon: Icons.sync_problem_rounded,
        );
      case SyncChipState.synced:
        final role = semantic.syncSynced;
        return (
          fg: role.ink,
          bg: role.subtle,
          border: role.border,
          icon: Icons.cloud_done_rounded,
        );
    }
  }

  String _defaultLabel(SharedCoreLocalizations t) {
    switch (state) {
      case SyncChipState.notSent:
        return t.pendingSyncNotSent;
      case SyncChipState.queued:
        return t.pendingSyncQueued;
      case SyncChipState.failed:
        return t.pendingSyncFailed;
      case SyncChipState.synced:
        return t.pendingSyncSynced;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = SharedCoreL10n.of(context);
    final resolved = _resolve(context);
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppDimensions.s6 : AppDimensions.s8,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: resolved.bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusXs),
        border: Border.all(color: resolved.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(resolved.icon, size: 12, color: resolved.fg),
          const SizedBox(width: AppDimensions.s4),
          Flexible(
            child: Text(
              label ?? _defaultLabel(t),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style:
                  (compact
                          ? Theme.of(context).textTheme.labelSmall
                          : Theme.of(context).textTheme.labelSmall)
                      ?.copyWith(
                        color: resolved.fg,
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 10 : 11,
                        letterSpacing: arabic ? 0 : 0.2,
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
