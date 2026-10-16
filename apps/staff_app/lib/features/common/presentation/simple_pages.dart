import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/local/sync_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

String? _clean(Map<String, dynamic> map, String key) {
  final val = map[key];
  if (val == null) return null;
  final str = val.toString().trim();
  if (str.isEmpty || str == '--') return null;
  return str;
}

// ─── SHIFT DETAILS ───────────────────────────────────────────────────────────
// Dossier-mini sibling of the advisor job dossier: schedule card owns the
// top (eyebrow + shift + start/end/breaks), assignment card follows
// (member/id/branch/supervisor/bay). Every row renders only when the pushed
// data map actually carries the value — omitted fields hide, never
// placeholders. No swap-request CTA exists: no swap endpoint or provider
// contract exists, so any such button would be a fake action (FAIL rule).
// Responsive via spec.pick only; all copy via l10n; all color via theme.
class ShiftDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ShiftDetailsPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final map = data ?? const <String, dynamic>{};

    final shift = _clean(map, 'shift') ?? t.staffShiftDefault;
    final start = _clean(map, 'start');
    final end = _clean(map, 'end');
    final breaks = _clean(map, 'breaks');
    final name = _clean(map, 'name');
    final id = _clean(map, 'id');
    final branch = _clean(map, 'branch');
    final supervisor = _clean(map, 'supervisor');
    final bay = _clean(map, 'bay');

    final hasScheduleDetail = start != null || end != null || breaks != null;
    final hasStaff =
        name != null ||
        id != null ||
        branch != null ||
        supervisor != null ||
        bay != null;
    // Empty only when the push carried nothing at all (no shift override
    // either — the default label counts as absent here).
    final isEmpty =
        _clean(map, 'shift') == null && !hasScheduleDetail && !hasStaff;

    final canPop = Navigator.of(context).canPop();
    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final scheduleCard = _ScheduleCard(
      shift: shift,
      start: start,
      end: end,
      breaks: breaks,
    );
    final staffCard = hasStaff
        ? _StaffContextCard(
            name: name,
            id: id,
            branch: branch,
            supervisor: supervisor,
            bay: bay,
          )
        : null;

    Widget body;
    if (isEmpty) {
      body = EmptyState(
        icon: Icons.schedule_outlined,
        message: t.staffShiftEmpty,
      );
    } else if (wide) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 5, child: scheduleCard),
          if (staffCard != null) ...[
            const SizedBox(width: AppDimensions.s24),
            Expanded(flex: 6, child: staffCard),
          ],
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          scheduleCard,
          if (staffCard != null) ...[
            const SizedBox(height: AppDimensions.s20),
            staffCard,
          ],
        ],
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: AppPageFrame(
          title: t.staffShiftTitle,
          subtitle: t.staffShiftSubtitle,
          leading: canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    context.pop();
                  },
                )
              : null,
          child: body,
        ),
      ),
    );
  }
}

class _ScheduleCard extends StatelessWidget {
  final String shift;
  final String? start;
  final String? end;
  final String? breaks;

  const _ScheduleCard({
    required this.shift,
    this.start,
    this.end,
    this.breaks,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(header: true, child: SectionHeader(title: t.staffShiftSchedule)),
        const SizedBox(height: AppDimensions.s8),
        Container(
          padding: const EdgeInsets.all(AppDimensions.s20),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.8),
            ),
            boxShadow: AppDimensions.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.primaryContainer.withValues(alpha: 0.6),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.schedule_rounded,
                      color: colors.primary,
                      size: AppDimensions.iconSm,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.staffShiftAssigned,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            fontSize: 10,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          shift,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colors.onSurface,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (start != null || end != null) ...[
                const SizedBox(height: AppDimensions.s16),
                Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppDimensions.s14),
                Row(
                  children: [
                    if (start != null)
                      Expanded(
                        child: _TimeCell(
                          label: t.staffShiftStart,
                          value: start!,
                        ),
                      ),
                    if (start != null && end != null)
                      Container(
                        width: 1,
                        height: 28,
                        color: colors.outlineVariant.withValues(alpha: 0.5),
                        margin: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.s12,
                        ),
                      ),
                    if (end != null)
                      Expanded(
                        child: _TimeCell(
                          label: t.staffShiftEnd,
                          value: end!,
                        ),
                      ),
                  ],
                ),
              ],
              if (breaks != null) ...[
                const SizedBox(height: AppDimensions.s14),
                Divider(
                  height: 1,
                  color: colors.outlineVariant.withValues(alpha: 0.5),
                ),
                const SizedBox(height: AppDimensions.s12),
                _DetailLine(
                  icon: Icons.coffee_outlined,
                  label: t.staffShiftBreaks,
                  value: breaks!,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimeCell extends StatelessWidget {
  final String label;
  final String value;

  const _TimeCell({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontFamily: AppFontFamilies.mono,
              color: theme.colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _StaffContextCard extends StatelessWidget {
  final String? name;
  final String? id;
  final String? branch;
  final String? supervisor;
  final String? bay;

  const _StaffContextCard({
    this.name,
    this.id,
    this.branch,
    this.supervisor,
    this.bay,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    final rows = <_DetailRowData>[
      if (name != null)
        _DetailRowData(
          icon: Icons.person_outline_rounded,
          label: t.staffShiftMember,
          value: name!,
        ),
      if (id != null)
        _DetailRowData(
          icon: Icons.badge_outlined,
          label: t.staffShiftEmpId,
          value: id!,
          isMono: true,
        ),
      if (branch != null)
        _DetailRowData(
          icon: Icons.business_outlined,
          label: t.staffShiftBranch,
          value: branch!,
        ),
      if (supervisor != null)
        _DetailRowData(
          icon: Icons.supervisor_account_outlined,
          label: t.staffShiftSupervisor,
          value: supervisor!,
        ),
      if (bay != null)
        _DetailRowData(
          icon: Icons.precision_manufacturing_outlined,
          label: t.staffShiftBay,
          value: bay!,
          isMono: true,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: SectionHeader(title: t.staffShiftAssignment),
        ),
        const SizedBox(height: AppDimensions.s8),
        Container(
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.8),
            ),
            boxShadow: AppDimensions.shadowCard,
          ),
          child: Column(
            children: [
              for (var i = 0; i < rows.length; i++) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s16,
                    vertical: AppDimensions.s12,
                  ),
                  child: MergeSemantics(
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest.withValues(
                              alpha: 0.4,
                            ),
                            borderRadius: BorderRadius.circular(
                              AppDimensions.radiusSm,
                            ),
                          ),
                          alignment: Alignment.center,
                          child: Icon(
                            rows[i].icon,
                            size: AppDimensions.iconSm,
                            color: colors.primary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.s12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                rows[i].label,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                rows[i].value,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontFamily: rows[i].isMono
                                      ? AppFontFamilies.mono
                                      : null,
                                  color: colors.onSurface,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < rows.length - 1)
                  Divider(
                    height: 1,
                    indent: 60,
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _DetailRowData {
  final IconData icon;
  final String label;
  final String value;
  final bool isMono;

  const _DetailRowData({
    required this.icon,
    required this.label,
    required this.value,
    this.isMono = false,
  });
}

class _DetailLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailLine({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Icon(icon, size: AppDimensions.iconSm, color: colors.primary),
        const SizedBox(width: AppDimensions.s10),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── SETTINGS ────────────────────────────────────────────────────────────────
// Honest sync diagnostics sibling of the advisor hub pill: pending count
// from the real queue lengths, a real Force Sync via the frozen engine, a
// session-only last-attempt stamp (no persisted contract exists), the real
// app version when pushed, an honest cached-item count via Hive lengths
// (no byte-size contract exists), and a guarded real cache clear. The pill
// owns offline state — no duplicate banner. No theme/notification/biometric
// toggles exist: no contracts, asserted by tests.
class SettingsPage extends ConsumerStatefulWidget {
  final Map<String, dynamic>? data;

  const SettingsPage({super.key, this.data});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool _syncing = false;
  DateTime? _lastAttempt;

  int _pendingCount() {
    try {
      final queue = ref.watch(syncQueueProvider).length;
      var failed = 0;
      try {
        if (Hive.isBoxOpen('sync_failed')) {
          failed = Hive.box('sync_failed').length;
        }
      } catch (_) {
        failed = 0;
      }
      return queue + failed;
    } catch (_) {
      return 0;
    }
  }

  int _cacheCount() {
    const boxes = <String>[
      'inspections',
      'repair_orders',
      'technician_jobs',
      'supervisor_assignments',
      'customer_bookings',
      'customer_breakdowns',
      'customer_cache',
      'owner_messages',
      'owner_activity',
      'pending_media',
    ];
    var total = 0;
    for (final name in boxes) {
      try {
        if (Hive.isBoxOpen(name)) total += Hive.box(name).length;
      } catch (_) {
        // A box that cannot be read contributes nothing — never a guess.
      }
    }
    return total;
  }

  void _toast(String msg, {required bool ok}) {
    final ink = context.semanticColors.onPrimary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ok
                  ? Icons.check_circle_outline_rounded
                  : Icons.error_outline_rounded,
              color: ink,
              size: AppDimensions.iconSm,
            ),
            const SizedBox(width: AppDimensions.s8),
            Expanded(
              child: Text(
                msg,
                style: TextStyle(color: ink, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        backgroundColor: ok
            ? context.semanticColors.success.base
            : Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _forceSync() async {
    if (_syncing) return;
    HapticFeedback.lightImpact();
    setState(() {
      _syncing = true;
      _lastAttempt = DateTime.now();
    });
    final t = StaffLocalizations.of(context)!;
    try {
      await ref.read(syncEngineProvider).syncAll();
      ref.invalidate(syncQueueProvider);
      if (mounted) _toast(t.staffSettingsSyncedToast, ok: true);
    } catch (_) {
      if (mounted) _toast(t.staffSettingsSyncFailed, ok: false);
    } finally {
      if (mounted) setState(() => _syncing = false);
    }
  }

  Future<void> _confirmClearCache(int pending) async {
    final t = StaffLocalizations.of(context)!;
    HapticFeedback.selectionClick();
    final confirmed = await showAppConfirmationDialog(
      context,
      title: t.staffSettingsClearTitle,
      message: t.staffSettingsClearBody,
      confirmLabel: t.staffSettingsClearCache,
      cancelLabel: MaterialLocalizations.of(context).cancelButtonLabel,
      icon: Icons.delete_outline_rounded,
      destructive: true,
    );
    if (!confirmed) return;
    HapticFeedback.heavyImpact();
    try {
      await HiveCleaner.clearAll();
      ref.invalidate(syncQueueProvider);
      if (mounted) _toast(t.staffSettingsCacheCleared, ok: true);
    } catch (_) {
      if (mounted) _toast(t.staffSettingsSyncFailed, ok: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final canPop = Navigator.of(context).canPop();

    final rawVersion = widget.data?['version'] as String?;
    final version = rawVersion != null && rawVersion.trim().isNotEmpty
        ? rawVersion.trim()
        : null;

    final pending = _pendingCount();
    final hasPending = pending > 0;
    final cacheCount = _cacheCount();

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final syncCard = _SyncDiagnosticsCard(
      pending: pending,
      lastAttempt: _lastAttempt,
      syncing: _syncing,
      onForceSync: _forceSync,
    );
    final appCard = version != null
        ? _AppVersionCard(version: version)
        : null;
    final cacheCard = _CacheCard(
      count: cacheCount,
      onClear: () => _confirmClearCache(pending),
    );

    Widget body;
    if (wide) {
      body = Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 5,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                syncCard,
                const SizedBox(height: AppDimensions.s24),
                const LanguageSwitcher(),
              ],
            ),
          ),
          const SizedBox(width: AppDimensions.s24),
          Expanded(
            flex: 6,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (appCard != null) ...[
                  appCard,
                  const SizedBox(height: AppDimensions.s24),
                ],
                cacheCard,
              ],
            ),
          ),
        ],
      );
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          syncCard,
          const SizedBox(height: AppDimensions.s24),
          const LanguageSwitcher(),
          if (appCard != null) ...[
            const SizedBox(height: AppDimensions.s24),
            appCard,
          ],
          const SizedBox(height: AppDimensions.s24),
          cacheCard,
        ],
      );
    }

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: AppPageFrame(
          title: t.staffSettingsTitle,
          subtitle: t.staffSettingsSubtitle,
          leading: canPop
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_rounded),
                  tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    context.pop();
                  },
                )
              : null,
          // The pill owns offline state — no duplicate banner on this page.
          trailing: OfflineStatusPill(pendingSyncCount: pending),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Semantic live region for the queue count (never color alone).
              Semantics(
                liveRegion: hasPending,
                label: hasPending
                    ? t.staffSettingsPending(pending)
                    : t.staffSettingsIdle,
                child: const SizedBox.shrink(),
              ),
              body,
              // Brand the page without stealing viewport: version line only
              // when the push carried nothing else to show.
              if (version == null) ...[
                const SizedBox(height: AppDimensions.s16),
                Text(
                  t.staffSettingsIdleHint,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ] else
                const SizedBox(height: AppDimensions.s32),
              // Keep the warning family honest: pending state explains
              // itself inside the card above, never as a bare red banner.
              if (hasPending)
                Row(
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: AppDimensions.iconXs,
                      color: semantic.warning.base,
                    ),
                    const SizedBox(width: AppDimensions.s6),
                    Expanded(
                      child: Text(
                        t.staffSettingsPendingHint,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Sync diagnostics card: queue-derived status, session last-attempt, and
/// the real Force Sync CTA with an honest busy label.
class _SyncDiagnosticsCard extends StatelessWidget {
  final int pending;
  final DateTime? lastAttempt;
  final bool syncing;
  final VoidCallback onForceSync;

  const _SyncDiagnosticsCard({
    required this.pending,
    required this.lastAttempt,
    required this.syncing,
    required this.onForceSync,
  });

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final hasPending = pending > 0;

    final tone = hasPending ? semantic.warning : semantic.success;
    final statusText = hasPending
        ? t.staffSettingsPending(pending)
        : t.staffSettingsIdle;
    final hintText =
        hasPending ? t.staffSettingsPendingHint : t.staffSettingsIdleHint;

    String? lastLine;
    if (lastAttempt != null) {
      final time = MaterialLocalizations.of(context).formatTimeOfDay(
        TimeOfDay.fromDateTime(lastAttempt!),
      );
      lastLine = t.staffSettingsLastAttempt(time);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: SectionHeader(title: t.staffSettingsSync),
        ),
        const SizedBox(height: AppDimensions.s8),
        Container(
          padding: const EdgeInsets.all(AppDimensions.s16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.8),
            ),
            boxShadow: AppDimensions.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: tone.subtle,
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                      border: Border.all(color: tone.border),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      hasPending
                          ? Icons.sync_problem_rounded
                          : Icons.cloud_done_outlined,
                      size: AppDimensions.iconSm,
                      color: tone.ink,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.staffSettingsSyncStatus,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statusText,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: colors.onSurface,
                            fontFeatures: const [
                              FontFeature.tabularFigures(),
                            ],
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          hintText,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                        if (lastLine != null) ...[
                          const SizedBox(height: 4),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              lastLine,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: colors.onSurfaceVariant,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (hasPending)
                    StatusPill.warning(t.staffSettingsPendingPill)
                  else
                    StatusPill.success(t.staffSettingsIdlePill),
                ],
              ),
              const SizedBox(height: AppDimensions.s16),
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: syncing ? null : onForceSync,
                  icon: syncing
                      ? SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: colors.onPrimary,
                          ),
                        )
                      : const Icon(Icons.sync_rounded, size: 20),
                  label: Text(
                    syncing
                        ? t.staffSettingsSyncing
                        : t.staffSettingsForceSync,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusButton,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AppVersionCard extends StatelessWidget {
  final String version;

  const _AppVersionCard({required this.version});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: SectionHeader(title: t.staffSettingsApp),
        ),
        const SizedBox(height: AppDimensions.s8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.s16,
            vertical: AppDimensions.s14,
          ),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.8),
            ),
            boxShadow: AppDimensions.shadowCard,
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                alignment: Alignment.center,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: AppDimensions.iconSm,
                  color: colors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.s14),
              Expanded(
                child: Text(
                  t.staffSettingsVersion,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  version,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontFamily: AppFontFamilies.mono,
                    color: colors.onSurface,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CacheCard extends StatelessWidget {
  final int count;
  final VoidCallback onClear;

  const _CacheCard({required this.count, required this.onClear});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: SectionHeader(title: t.staffSettingsCache),
        ),
        const SizedBox(height: AppDimensions.s8),
        Container(
          padding: const EdgeInsets.all(AppDimensions.s16),
          decoration: BoxDecoration(
            color: colors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
            border: Border.all(
              color: colors.outlineVariant.withValues(alpha: 0.8),
            ),
            boxShadow: AppDimensions.shadowCard,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: colors.surfaceContainerHighest.withValues(
                        alpha: 0.4,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusSm,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.sd_storage_outlined,
                      size: AppDimensions.iconSm,
                      color: colors.primary,
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.staffSettingsCache,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            t.staffSettingsCacheHint(count),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colors.onSurface,
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppDimensions.s16),
              SizedBox(
                height: AppDimensions.touchTarget,
                child: OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    onClear();
                  },
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: AppDimensions.iconSm,
                  ),
                  label: Text(
                    t.staffSettingsClearCache,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: colors.error,
                    side: BorderSide(
                      color: colors.error.withValues(alpha: 0.35),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppDimensions.radiusButton,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
