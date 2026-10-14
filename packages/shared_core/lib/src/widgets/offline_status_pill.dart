import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/src/localization/shared_core_l10n.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/theme/app_text_styles.dart';
import 'package:shared_core/src/theme/app_theme_context.dart';
import 'package:shared_core/src/widgets/offline_banner.dart';

/// **Integrated offline telemetry pill (Phase 04).**
///
/// A compact app-bar companion to [OfflineBanner]. It reads the **same**
/// connectivity source of truth (`connectivityStatusProvider`) so the two can
/// never contradict each other — it never creates its own connectivity state.
///
/// States (icon + text + colour, never colour alone):
/// - queued local changes → info family + `sync` glyph + `{n} queued`;
/// - offline (nothing queued) → warning family + `cloud_off` + "Offline";
/// - online → success family + `cloud_done` + "Synced".
///
/// Integration rule: use the pill **or** the full-width [OfflineBanner], not
/// both. [DashboardShell] exposes `showOfflineBanner` so a shell that shows this
/// pill in its app bar can suppress the banner and avoid duplicate indicators.
class OfflineStatusPill extends ConsumerWidget {
  /// Number of local changes waiting to sync. Supplied by the caller from the
  /// existing sync queue; null is treated as zero.
  final int? pendingSyncCount;

  final VoidCallback? onTap;

  const OfflineStatusPill({super.key, this.pendingSyncCount, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(connectivityStatusProvider).value;
    final offline = status == ConnectivityResult.none;
    final queued = pendingSyncCount ?? 0;
    final t = SharedCoreL10n.of(context);
    final semantic = context.semanticColors;
    final arabic = AppTypography.isArabic(Localizations.maybeLocaleOf(context));

    final bool isQueued = queued > 0;
    final bool isOffline = !isQueued && offline;

    final ({Color bg, Color ink, Color ring, IconData icon, String text}) tone;
    if (isQueued) {
      final role = semantic.syncQueued;
      tone = (
        bg: role.subtle,
        ink: role.ink,
        ring: role.border,
        icon: Icons.sync_rounded,
        text: t.connectivityQueuedCount(queued),
      );
    } else if (isOffline) {
      final role = semantic.warning;
      tone = (
        bg: role.subtle,
        ink: role.ink,
        ring: role.border,
        icon: Icons.cloud_off_rounded,
        text: t.connectivityOffline,
      );
    } else {
      final role = semantic.success;
      tone = (
        bg: role.subtle,
        ink: role.ink,
        ring: role.border,
        icon: Icons.cloud_done_rounded,
        text: t.connectivityOnline,
      );
    }

    final pill = Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s8,
        vertical: AppDimensions.s4,
      ),
      decoration: BoxDecoration(
        color: tone.bg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
        border: Border.all(color: tone.ring),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tone.icon, size: AppDimensions.iconXs, color: tone.ink),
          const SizedBox(width: AppDimensions.s4),
          Text(
            tone.text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTextStyles.metadata(
              color: tone.ink,
              arabic: arabic,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );

    return Semantics(
      liveRegion: isOffline,
      label: tone.text,
      button: onTap != null,
      child: onTap == null
          ? pill
          : InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(AppDimensions.radiusPill),
              child: pill,
            ),
    );
  }
}
