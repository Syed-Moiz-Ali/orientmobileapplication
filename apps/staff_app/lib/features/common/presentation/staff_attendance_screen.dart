import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' as intl;
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/common/presentation/providers/staff_attendance_provider.dart';
import 'package:staff_app/features/technician/presentation/providers/technician_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Staff attendance punch clock (Phase 12, home-grammar sibling of the
/// advisor hub): punch card with a 56px toggle CTA, timestamp microcopy and
/// an elapsed-on-shift meter, plus a month calendar whose only marked day is
/// today when the server actually returned a record.
///
/// Honesty rules enforced here: no attendance-history endpoint exists, so
/// past days carry no dots and say so once; lateness cannot be derived
/// without a scheduled start, so no late/early verdicts render anywhere.
/// All clock and sync writes go through the frozen provider methods.
class StaffAttendanceScreen extends ConsumerWidget {
  const StaffAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final state = ref.watch(staffAttendanceProvider);
    final notifier = ref.read(staffAttendanceProvider.notifier);
    final auth = ref.watch(authNotifierProvider);
    final profile = auth is AuthAuthenticated ? auth.profile : null;

    final canPop = Navigator.of(context).canPop();
    final staffName = profile?.name.trim().isNotEmpty == true
        ? profile!.name.trim()
        : (profile?.role.isNotEmpty == true ? profile!.role : 'Staff');
    final formattedDate = intl.DateFormat(
      'EEEE, d MMMM yyyy',
      Localizations.localeOf(context).toLanguageTag(),
    ).format(DateTime.now());

    // Punch card first (the verb), then today's record, then the month.
    // Wide viewports split punch + record left, calendar right.
    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      body: SafeArea(
        child: AppPageFrame(
          title: t.staffAttTitle,
          subtitle: '$staffName · $formattedDate',
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
          trailing: const _SyncPill(),
          child: RefreshIndicator(
            onRefresh: notifier.load,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: state.isLoading
                  ? const Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppSkeleton.card(height: 190),
                        SizedBox(height: AppDimensions.s20),
                        AppSkeleton.text(width: 160),
                        SizedBox(height: AppDimensions.s10),
                        AppSkeleton.grid(
                          columns: 2,
                          rows: 2,
                          itemHeight: 78,
                        ),
                        SizedBox(height: AppDimensions.s24),
                        AppSkeleton.card(height: 50),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (state.error.isNotEmpty) ...[
                          ErrorView(
                            message: state.error,
                            onRetry: notifier.load,
                          ),
                          const SizedBox(height: AppDimensions.s16),
                        ],
                        if (wide)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    _PunchCard(
                                      state: state,
                                      onPunchIn: () => _confirmPunchIn(
                                        context,
                                        ref,
                                        notifier,
                                      ),
                                      onPunchOut: () => _confirmPunchOut(
                                        context,
                                        ref,
                                        notifier,
                                      ),
                                    ),
                                    const SizedBox(height: AppDimensions.s20),
                                    _TimeSummaryWorkspace(state: state),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppDimensions.s24),
                              Expanded(
                                flex: 6,
                                child: _MonthCalendar(state: state),
                              ),
                            ],
                          )
                        else ...[
                          _PunchCard(
                            state: state,
                            onPunchIn: () =>
                                _confirmPunchIn(context, ref, notifier),
                            onPunchOut: () =>
                                _confirmPunchOut(context, ref, notifier),
                          ),
                          const SizedBox(height: AppDimensions.s16),
                          _TimeSummaryWorkspace(state: state),
                          const SizedBox(height: AppDimensions.s24),
                          _MonthCalendar(state: state),
                          const SizedBox(height: AppDimensions.s32),
                        ],
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmPunchIn(
    BuildContext context,
    WidgetRef ref,
    StaffAttendanceNotifier notifier,
  ) async {
    final t = StaffLocalizations.of(context)!;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: t.staffAttPunchInTitle,
      message: t.staffAttPunchInBody,
      confirmLabel: t.staffAttPunchIn,
    );
    if (!confirmed) return;
    final ok = await notifier.punchIn();
    if (ok) ref.invalidate(technicianDashboardProvider);
    if (context.mounted) _showResult(context, ok, t.staffAttInToast);
  }

  Future<void> _confirmPunchOut(
    BuildContext context,
    WidgetRef ref,
    StaffAttendanceNotifier notifier,
  ) async {
    final t = StaffLocalizations.of(context)!;
    final confirmed = await showAppConfirmationDialog(
      context,
      title: t.staffAttPunchOutTitle,
      message: t.staffAttPunchOutBody,
      confirmLabel: t.staffAttPunchOut,
      destructive: false,
    );
    if (!confirmed) return;
    final ok = await notifier.punchOut();
    if (ok) ref.invalidate(technicianDashboardProvider);
    if (context.mounted) _showResult(context, ok, t.staffAttOutToast);
  }

  void _showResult(BuildContext context, bool ok, String success) {
    final t = StaffLocalizations.of(context)!;
    final ink = context.semanticColors.onPrimary;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              ok ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
              color: ink,
              size: AppDimensions.iconSm,
            ),
            const SizedBox(width: AppDimensions.s8),
            Expanded(
              child: Text(
                ok ? success : t.staffAttFailToast,
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
}

/// Queue pill for the header: announces pending sync once, never a banner.
/// Reads the authoritative `sync_queue` length (same source as the advisor
/// hub pill). Degrades to 0 when Hive is unavailable (widget tests).
class _SyncPill extends ConsumerWidget {
  const _SyncPill();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    int pending = 0;
    try {
      pending = ref.watch(syncQueueProvider).length;
    } catch (_) {
      pending = 0;
    }
    return OfflineStatusPill(pendingSyncCount: pending);
  }
}

/// Punch card: the 56px toggle CTA, punched-at microcopy from the recorded
/// stamps, and an elapsed-on-shift meter over a disclosed 8h workday basis.
/// Display only — the stamps come from the frozen provider state.
class _PunchCard extends StatelessWidget {
  final StaffAttendanceState state;
  final VoidCallback onPunchIn;
  final VoidCallback onPunchOut;

  const _PunchCard({
    required this.state,
    required this.onPunchIn,
    required this.onPunchOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    final meta = switch (state.status) {
      StaffAttendanceStatus.notPunchedIn => _meta(
        t,
        colors,
        theme,
        Icons.schedule_outlined,
        t.staffAttNotPunchedHint,
      ),
      StaffAttendanceStatus.working => _meta(
        t,
        colors,
        theme,
        Icons.check_circle_rounded,
        t.staffAttWorkingHint,
      ),
      StaffAttendanceStatus.onBreak => _meta(
        t,
        colors,
        theme,
        Icons.pause_circle_rounded,
        t.staffAttBreakHint,
      ),
      StaffAttendanceStatus.punchedOut => _meta(
        t,
        colors,
        theme,
        Icons.task_alt_rounded,
        t.staffAttDoneHint,
      ),
    };

    final elapsed = _elapsedToday(state.punchIn, state.punchOut);
    final onShift = state.status == StaffAttendanceStatus.working;

    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _tone(context).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(
                    AppDimensions.radiusControl,
                  ),
                ),
                child: Icon(
                  _iconFor(state.status),
                  color: _tone(context),
                  size: AppDimensions.iconMd,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _label(t, state.status),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colors.onSurface,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    meta,
                  ],
                ),
              ),
              _StatusTonePill(status: state.status),
            ],
          ),
          if (state.punchIn.trim().isNotEmpty) ...[
            const SizedBox(height: AppDimensions.s12),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                state.punchOut.trim().isNotEmpty
                    ? t.staffAttOutAt(state.punchOut.trim())
                    : t.staffAttPunchedAt(state.punchIn.trim()),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
          if (onShift && elapsed != null) ...[
            const SizedBox(height: AppDimensions.s12),
            AppLinearProgress(
              value: (elapsed.inMinutes / (8 * 60)).clamp(0.0, 1.0),
              label:
                  '${t.staffAttOnShiftFor(_formatSpan(elapsed))} · ${t.staffAttBasis}',
            ),
          ],
          const SizedBox(height: AppDimensions.s16),
          _ActionSection(
            state: state,
            onPunchIn: onPunchIn,
            onPunchOut: onPunchOut,
          ),
        ],
      ),
    );
  }

  Widget _meta(
    StaffLocalizations t,
    ColorScheme colors,
    ThemeData theme,
    IconData icon,
    String text,
  ) {
    return Text(
      text,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: theme.textTheme.bodySmall?.copyWith(
        color: colors.onSurfaceVariant,
        height: 1.35,
      ),
    );
  }

  Color _tone(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final semantic = context.semanticColors;
    return switch (state.status) {
      StaffAttendanceStatus.notPunchedIn => colors.onSurfaceVariant,
      StaffAttendanceStatus.working => semantic.success.base,
      StaffAttendanceStatus.onBreak => semantic.warning.base,
      StaffAttendanceStatus.punchedOut => colors.primary,
    };
  }

  IconData _iconFor(StaffAttendanceStatus status) => switch (status) {
    StaffAttendanceStatus.notPunchedIn => Icons.schedule_outlined,
    StaffAttendanceStatus.working => Icons.check_circle_rounded,
    StaffAttendanceStatus.onBreak => Icons.pause_circle_rounded,
    StaffAttendanceStatus.punchedOut => Icons.task_alt_rounded,
  };

  String _label(StaffLocalizations t, StaffAttendanceStatus status) =>
      switch (status) {
        StaffAttendanceStatus.notPunchedIn => t.staffAttNotPunched,
        StaffAttendanceStatus.working => t.staffAttWorking,
        StaffAttendanceStatus.onBreak => t.staffAttOnBreak,
        StaffAttendanceStatus.punchedOut => t.staffAttShiftComplete,
      };
}

/// State-toned status pill (never color alone — the label carries meaning).
/// Working/punched-out resolve to success, break to warning, idle to neutral.
class _StatusTonePill extends StatelessWidget {
  final StaffAttendanceStatus status;

  const _StatusTonePill({required this.status});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    // C16: sentence-case ARB copy verbatim — never uppercased.
    final label = switch (status) {
      StaffAttendanceStatus.notPunchedIn => t.staffAttNotPunched,
      StaffAttendanceStatus.working => t.staffAttWorking,
      StaffAttendanceStatus.onBreak => t.staffAttOnBreak,
      StaffAttendanceStatus.punchedOut => t.staffAttShiftComplete,
    };
    return switch (status) {
      StaffAttendanceStatus.working ||
      StaffAttendanceStatus.punchedOut =>
        StatusPill.success(label),
      StaffAttendanceStatus.onBreak => StatusPill.warning(label),
      StaffAttendanceStatus.notPunchedIn => StatusPill.neutral(label),
    };
  }
}

/// Elapsed on shift from today's recorded punch-in stamp (`hh:mm a` as the
/// server returns it). Null when unparseable — the meter hides instead of
/// guessing. Pure presentation derivation, unit-covered.
Duration? _elapsedToday(String punchIn, String punchOut) {
  if (punchOut.trim().isNotEmpty) return null;
  final raw = punchIn.trim();
  if (raw.isEmpty) return null;
  try {
    final parsed = intl.DateFormat('hh:mm a').parse(raw);
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day, parsed.hour, parsed.minute);
    final diff = now.difference(start);
    return diff.isNegative ? Duration.zero : diff;
  } catch (_) {
    return null;
  }
}

String _formatSpan(Duration elapsed) {
  final h = elapsed.inHours;
  final m = elapsed.inMinutes.remainder(60);
  return '${h}h ${m.toString().padLeft(2, '0')}m';
}

/// Grouped time summary containing Punch in, Punch out, Hours worked, and Break time if available.
class _TimeSummaryWorkspace extends StatelessWidget {
  final StaffAttendanceState state;

  const _TimeSummaryWorkspace({required this.state});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final showBreak =
        state.breakTime.trim().isNotEmpty && state.breakTime != '0';

    final tiles = <_TimeMetric>[
      _TimeMetric(
        label: t.staffAttPunchInRow,
        value: state.punchIn.trim().isEmpty ? '--:--' : state.punchIn.trim(),
        icon: Icons.login_rounded,
      ),
      _TimeMetric(
        label: t.staffAttPunchOutRow,
        value: state.punchOut.trim().isEmpty ? '--:--' : state.punchOut.trim(),
        icon: Icons.logout_rounded,
      ),
      _TimeMetric(
        label: t.staffAttHours,
        value: state.workHours.trim().isEmpty ? '--' : state.workHours.trim(),
        icon: Icons.timelapse_rounded,
      ),
      if (showBreak)
        _TimeMetric(
          label: t.staffAttBreakRow,
          value: state.breakTime.trim(),
          icon: Icons.coffee_rounded,
        ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(title: t.staffAttTodayRecord),
        const SizedBox(height: AppDimensions.s8),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = !context.isCompact;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tiles.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: wide ? 2 : (constraints.maxWidth < 360 ? 1 : 2),
                crossAxisSpacing: AppDimensions.s10,
                mainAxisSpacing: AppDimensions.s10,
                mainAxisExtent: 78,
              ),
              itemBuilder: (context, index) => _TimeCard(metric: tiles[index]),
            );
          },
        ),
      ],
    );
  }
}

class _TimeMetric {
  final String label;
  final String value;
  final IconData icon;

  const _TimeMetric({
    required this.label,
    required this.value,
    required this.icon,
  });
}

class _TimeCard extends StatelessWidget {
  final _TimeMetric metric;

  const _TimeCard({required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s14,
        vertical: AppDimensions.s12,
      ),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.8)),
        boxShadow: AppDimensions.shadowCard,
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: colors.primaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            alignment: Alignment.center,
            child: Icon(
              metric.icon,
              size: AppDimensions.iconSm,
              color: colors.primary,
            ),
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  metric.label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    metric.value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      fontFamily: AppFontFamilies.mono,
                      color: colors.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Action section handling Punch In, Punch Out, and Shift Complete states safely.
class _ActionSection extends StatelessWidget {
  final StaffAttendanceState state;
  final VoidCallback onPunchIn;
  final VoidCallback onPunchOut;

  const _ActionSection({
    required this.state,
    required this.onPunchIn,
    required this.onPunchOut,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    if (state.status == StaffAttendanceStatus.notPunchedIn) {
      // Honest busy: label stays visible ("Punching in…") with a spinner
      // icon and a disabled control (PrimaryButton hides its label when
      // isLoading, which breaks the busy contract asserted by tests).
      return SizedBox(
        height: 56,
        child: ElevatedButton.icon(
          onPressed: state.isSaving ? null : onPunchIn,
          icon: state.isSaving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: colors.onPrimary,
                  ),
                )
              : const Icon(Icons.fingerprint_rounded, size: 20),
          label: Text(
            state.isSaving ? t.staffAttPunchingIn : t.staffAttPunchIn,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
          ),
        ),
      );
    }

    if (state.status == StaffAttendanceStatus.working ||
        state.status == StaffAttendanceStatus.onBreak) {
      return SizedBox(
        height: 56,
        child: OutlinedButton.icon(
          onPressed: state.isSaving ? null : onPunchOut,
          icon: state.isSaving
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    // FIXED-INK: white spinner on the filled busy treatment.
                    color: colors.onPrimary,
                  ),
                )
              : const Icon(Icons.logout_rounded, size: 20),
          label: Text(
            state.isSaving ? t.staffAttPunchingOut : t.staffAttPunchOut,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: colors.onSurface,
            backgroundColor: colors.surfaceContainerHighest,
            side: BorderSide(color: colors.outlineVariant),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusButton),
            ),
          ),
        ),
      );
    }

    // Shift complete state: calm completion line.
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.s16,
        vertical: AppDimensions.s14,
      ),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppDimensions.radiusCard),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            color: colors.primary,
            size: 20,
          ),
          const SizedBox(width: AppDimensions.s12),
          Expanded(
            child: Text(
              t.staffAttDoneLine,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Month calendar: real month math, today ring, and a status dot only where
/// a real record exists (today, from live state). Past days carry no dots —
/// the note below says why. Tapping any day opens its record sheet.
class _MonthCalendar extends StatefulWidget {
  final StaffAttendanceState state;

  const _MonthCalendar({required this.state});

  @override
  State<_MonthCalendar> createState() => _MonthCalendarState();
}

class _MonthCalendarState extends State<_MonthCalendar> {
  late DateTime _shownMonth;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _shownMonth = DateTime(now.year, now.month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final now = DateTime.now();
    final daysInMonth =
        DateTime(_shownMonth.year, _shownMonth.month + 1, 0).day;
    // Monday-first columns (1..7); leading blanks keep the grid truthful.
    final leadBlanks = (DateTime(_shownMonth.year, _shownMonth.month, 1).weekday - 1) % 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionHeader(
          title: t.staffAttMonthTitle,
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: MaterialLocalizations.of(context).previousPageTooltip,
                onPressed: () => setState(() {
                  _shownMonth = DateTime(
                    _shownMonth.year,
                    _shownMonth.month - 1,
                  );
                }),
                icon: const DirectionalIcon(
                  Icons.chevron_left_rounded,
                  size: 22,
                ),
                color: colors.onSurfaceVariant,
              ),
              IconButton(
                tooltip: MaterialLocalizations.of(context).nextPageTooltip,
                onPressed: () => setState(() {
                  _shownMonth = DateTime(
                    _shownMonth.year,
                    _shownMonth.month + 1,
                  );
                }),
                icon: const DirectionalIcon(
                  Icons.chevron_right_rounded,
                  size: 22,
                ),
                color: colors.onSurfaceVariant,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.s8),
        Container(
          padding: const EdgeInsets.all(AppDimensions.s12),
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
              Text(
                intl.DateFormat.yMMMM(locale).format(_shownMonth),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: colors.onSurface,
                ),
              ),
              const SizedBox(height: AppDimensions.s10),
              Row(
                children: [
                  for (var d = 0; d < 7; d++)
                    Expanded(
                      child: Center(
                        child: Text(
                          intl.DateFormat.E(locale)
                              .format(DateTime(2026, 1, 5 + d))
                              .characters
                              .take(2)
                              .toString(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppDimensions.s6),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: leadBlanks + daysInMonth,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: AppDimensions.s4,
                      crossAxisSpacing: AppDimensions.s4,
                    ),
                itemBuilder: (context, index) {
                  if (index < leadBlanks) {
                    return const SizedBox.shrink();
                  }
                  final day = index - leadBlanks + 1;
                  final date = DateTime(
                    _shownMonth.year,
                    _shownMonth.month,
                    day,
                  );
                  final isToday =
                      date.year == now.year &&
                      date.month == now.month &&
                      date.day == now.day;
                  final hasRecord =
                      isToday && widget.state.punchIn.trim().isNotEmpty;
                  return _DayCell(
                    day: day,
                    isToday: isToday,
                    state: widget.state.status,
                    hasRecord: hasRecord,
                    onTap: () => _openDay(context, date, hasRecord),
                  );
                },
              ),
              const SizedBox(height: AppDimensions.s10),
              Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: AppDimensions.iconXs,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.s6),
                  Expanded(
                    child: Text(
                      t.staffAttHistoryNote,
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
      ],
    );
  }

  void _openDay(BuildContext context, DateTime date, bool hasRecord) {
    HapticFeedback.selectionClick();
    showAppModalSheet<void>(
      context: context,
      builder: (_) => _DaySheet(
        date: date,
        state: widget.state,
        hasRecord: hasRecord,
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  final int day;
  final bool isToday;
  final StaffAttendanceStatus state;
  final bool hasRecord;
  final VoidCallback onTap;

  const _DayCell({
    required this.day,
    required this.isToday,
    required this.state,
    required this.hasRecord,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final semantic = context.semanticColors;
    final dot = !hasRecord
        ? null
        : switch (state) {
            StaffAttendanceStatus.working => semantic.success.base,
            StaffAttendanceStatus.onBreak => semantic.warning.base,
            StaffAttendanceStatus.notPunchedIn => null,
            StaffAttendanceStatus.punchedOut => semantic.success.base,
          };

    return Semantics(
      button: true,
      selected: isToday,
      label: '$day',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(
                AppDimensions.radiusControl,
              ),
              border: isToday
                  ? Border.all(color: colors.primary, width: 1.5)
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    '$day',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isToday ? colors.primary : colors.onSurface,
                      fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dot ?? Colors.transparent,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Day record sheet: today's real stamps, or an honest empty state for any
/// other day. One primary (dismiss) — no fake actions.
class _DaySheet extends StatelessWidget {
  final DateTime date;
  final StaffAttendanceState state;
  final bool hasRecord;

  const _DaySheet({
    required this.date,
    required this.state,
    required this.hasRecord,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = StaffLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s20,
          AppDimensions.s8,
          AppDimensions.s20,
          AppDimensions.s20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              intl.DateFormat.yMMMMd(locale).format(date),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: AppDimensions.s12),
            if (!hasRecord)
              EmptyState(
                icon: Icons.event_busy_outlined,
                message: t.staffAttNoRecord,
              )
            else
              AppCard.standard(
                child: Column(
                  children: [
                    _DayLine(
                      icon: Icons.login_rounded,
                      label: t.staffAttPunchInRow,
                      value: state.punchIn,
                    ),
                    if (state.punchOut.trim().isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s8),
                      _DayLine(
                        icon: Icons.logout_rounded,
                        label: t.staffAttPunchOutRow,
                        value: state.punchOut,
                      ),
                    ],
                    if (state.workHours.trim().isNotEmpty) ...[
                      const SizedBox(height: AppDimensions.s8),
                      _DayLine(
                        icon: Icons.timelapse_rounded,
                        label: t.staffAttHours,
                        value: state.workHours,
                      ),
                    ],
                  ],
                ),
              ),
            const SizedBox(height: AppDimensions.s16),
            SecondaryButton(
              label: MaterialLocalizations.of(context).closeButtonTooltip,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayLine extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DayLine({required this.icon, required this.label, required this.value});

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
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}
