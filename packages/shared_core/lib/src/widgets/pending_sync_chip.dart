import 'package:flutter/material.dart';
import 'package:shared_core/l10n/gen/shared_core_localizations.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_colors.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';

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
    final dark = Theme.of(context).brightness == Brightness.dark;
    switch (state) {
      case SyncChipState.notSent:
        return (
          fg: dark ? AppDarkColors.warning : const Color(0xFFB45309),
          bg: dark ? AppDarkColors.warningSubtle : AppColors.warningSubtle,
          border: dark ? AppDarkColors.warningBorder : AppColors.warningBorder,
          icon: Icons.cloud_off_rounded,
        );
      case SyncChipState.queued:
        return (
          fg: dark ? AppDarkColors.info : const Color(0xFF4338CA),
          bg: dark ? AppDarkColors.infoSubtle : AppColors.infoSubtle,
          border: dark ? AppDarkColors.infoBorder : AppColors.infoBorder,
          icon: Icons.schedule_send_rounded,
        );
      case SyncChipState.failed:
        return (
          fg: dark ? AppDarkColors.danger : const Color(0xFFB91C1C),
          bg: dark ? AppDarkColors.dangerSubtle : AppColors.dangerSubtle,
          border: dark ? AppDarkColors.dangerBorder : AppColors.dangerBorder,
          icon: Icons.sync_problem_rounded,
        );
      case SyncChipState.synced:
        return (
          fg: dark ? AppDarkColors.success : const Color(0xFF15803D),
          bg: dark ? AppDarkColors.successSubtle : AppColors.successSubtle,
          border: dark ? AppDarkColors.successBorder : AppColors.successBorder,
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
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
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
