import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/core/router/app_router.dart';
import 'package:owner_app/features/job_cards/domain/entities/job_card.dart';
import 'package:owner_app/features/job_cards/presentation/providers/job_card_providers.dart';
import 'package:owner_app/features/job_cards/presentation/widgets/job_status_ui.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Executive job audit (O6): identity header with breadcrumbs, the
/// six-stage lifecycle stepper, services / assignment panels, a totals dock
/// with the single real state change (`markComplete`) and share. Parts
/// margin, labor profitability, discount history and invoice status have no
/// endpoint fields — the financials panel states its scope honestly instead
/// of inventing panels. Wide viewports split dossier + rail; compact docks
/// the totals.
class JobCardDetailView extends ConsumerStatefulWidget {
  const JobCardDetailView({super.key});

  @override
  ConsumerState<JobCardDetailView> createState() => _JobCardDetailViewState();
}

class _JobCardDetailViewState extends ConsumerState<JobCardDetailView> {
  bool _completing = false;

  Future<void> _shareJobCard(JobCard jc) async {
    final summary = '''
${jc.id}
Customer: ${jc.customerName}
Vehicle: ${jc.vehicleDisplay}
Services: ${jc.services.join(', ')}
Technician: ${jc.technician}
Est. Completion: ${jc.estCompletion}
Status: ${jc.status.name}
Amount: AED ${jc.amount.toStringAsFixed(2)}
''';
    HapticFeedback.selectionClick();
    await Share.share(summary, subject: 'Job Card ${jc.id}');
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

  Future<void> _confirmComplete(JobCard jc) async {
    final t = OwnerLocalizations.of(context)!;
    HapticFeedback.selectionClick();
    final confirmed = await showAppConfirmationDialog(
      context,
      title: t.ownerDetConfirmTitle,
      message: t.ownerDetConfirmBody,
      confirmLabel: t.ownerDetComplete,
      cancelLabel: t.ownerDetCancel,
      icon: Icons.check_circle_outline_rounded,
    );
    if (!confirmed || !mounted) return;
    setState(() => _completing = true);
    final ok =
        await ref.read(jobCardsProvider.notifier).markComplete(jc.id);
    if (!mounted) return;
    setState(() => _completing = false);
    _toast(ok ? t.ownerDetDone : t.ownerDetFail, ok: ok);
  }

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final jobCard = ref.watch(selectedJobCardProvider);

    if (jobCard == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: WorkspaceAppBar(
          title: t.ownerRegTitle,
          showBack: true,
        ),
        body: SafeArea(
          child: AppPageFrame(
            child: Column(
              children: [
                EmptyState(
                  icon: Icons.assignment_outlined,
                  message: t.ownerDetEmpty,
                ),
                const SizedBox(height: AppDimensions.s8),
                Text(
                  t.ownerDetEmptyHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final jc = jobCard;
    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    final dossier = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LifecycleCard(status: jc.status),
        const SizedBox(height: AppDimensions.s16),
        _ServicesPanel(jobCard: jc),
        const SizedBox(height: AppDimensions.s16),
        _AssignmentPanel(jobCard: jc),
      ],
    );
    final rail = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FinancialsPanel(jobCard: jc),
        const SizedBox(height: AppDimensions.s16),
        _ActionsCard(
          jobCard: jc,
          completing: _completing,
          onComplete: () => _confirmComplete(jc),
          onShare: () => _shareJobCard(jc),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: jc.id,
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, size: 22),
            tooltip: t.ownerDetShare,
            onPressed: () => _shareJobCard(jc),
          ),
        ],
      ),
      bottomNavigationBar: wide
          ? null
          : _TotalsDock(
              jobCard: jc,
              completing: _completing,
              onComplete: () => _confirmComplete(jc),
            ),
      body: SafeArea(
        child: AppPageFrame(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppPageHeader(
                breadcrumbs: [
                  AppBreadcrumbItem(
                    label: t.ownerDetJobs,
                    onTap: () => context.push(AppRoutes.jobCards),
                  ),
                  AppBreadcrumbItem.current(jc.id),
                ],
                title: jc.customerName,
                subtitle: jc.vehicleDisplay,
                trailing: jobStatusPill(context, t, jc.status),
              ),
              const SizedBox(height: AppDimensions.s20),
              if (wide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: dossier),
                    const SizedBox(width: AppDimensions.s24),
                    Expanded(flex: 2, child: rail),
                  ],
                )
              else ...[
                dossier,
                const SizedBox(height: AppDimensions.s16),
                rail,
                // Dock clearance so content never hides behind the CTA.
                const SizedBox(height: AppDimensions.s64),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Lifecycle position card: the six dossier steps driven by the live status.
/// Needs ~560px, so compact scrolls it horizontally (same bound as the
/// advisor dossier); cancellation rests at intake with its pill carrying
/// the terminal state.
class _LifecycleCard extends StatelessWidget {
  final JobCardStatus status;

  const _LifecycleCard({required this.status});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    return AppCard.standard(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 560,
          child: AppStepper(
            steps: [
              t.ownerDetStepIntake,
              t.ownerDetStepInspect,
              t.ownerDetStepEstimate,
              t.ownerDetStepRepair,
              t.ownerDetStepQc,
              t.ownerDetStepReady,
            ],
            currentIndex: jobLifecycleIndex(status),
          ),
        ),
      ),
    );
  }
}

class _ServicesPanel extends StatelessWidget {
  final JobCard jobCard;

  const _ServicesPanel({required this.jobCard});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: t.ownerDetServices,
            leadingIcon: Icons.build_circle_rounded,
            padding: const EdgeInsets.only(bottom: AppDimensions.s12),
          ),
          if (jobCard.services.isEmpty)
            Text(
              t.ownerDetNoServices,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            )
          else
            for (final service in jobCard.services)
              Padding(
                padding: const EdgeInsets.only(bottom: AppDimensions.s8),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: colors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.s10),
                    Expanded(
                      child: Text(
                        service,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
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

class _AssignmentPanel extends StatelessWidget {
  final JobCard jobCard;

  const _AssignmentPanel({required this.jobCard});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(
            title: t.ownerDetAssign,
            leadingIcon: Icons.info_outline_rounded,
            padding: const EdgeInsets.only(bottom: AppDimensions.s12),
          ),
          _FactRow(label: t.ownerDetTech, value: jobCard.technician),
          Divider(
            height: AppDimensions.s20,
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
          _FactRow(label: t.ownerDetEta, value: jobCard.estCompletion),
          Divider(
            height: AppDimensions.s20,
            color: colors.outlineVariant.withValues(alpha: 0.6),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  t.ownerDetStage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant,
                  ),
                ),
              ),
              jobStatusPill(context, t, jobCard.status),
            ],
          ),
        ],
      ),
    );
  }
}

class _FactRow extends StatelessWidget {
  final String label;
  final String value;

  const _FactRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.s12),
        Flexible(
          child: Text(
            value.isEmpty ? '—' : value,
            textAlign: TextAlign.end,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: colors.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Financials: the record total in fixed-decimal tabular money plus the
/// honest scope note. Parts margin, labor profitability, discount history
/// and invoice status have no endpoint fields — deferred, documented.
class _FinancialsPanel extends StatelessWidget {
  final JobCard jobCard;

  const _FinancialsPanel({required this.jobCard});

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final formatters = AppFormatters.of(context);
    return AppCard.standard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  t.ownerDetTotal,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colors.onSurfaceVariant,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Text(
                  formatAed2(formatters, jobCard.amount),
                  style: AppTextStyles.mono(color: colors.primary).copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s8),
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
                  t.ownerDetSplitNote,
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
    );
  }
}

class _ActionsCard extends StatelessWidget {
  final JobCard jobCard;
  final bool completing;
  final VoidCallback onComplete;
  final VoidCallback onShare;

  const _ActionsCard({
    required this.jobCard,
    required this.completing,
    required this.onComplete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final alreadyDone = jobCard.status == JobCardStatus.completed ||
        jobCard.status == JobCardStatus.delivered;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrimaryButton(
          label: t.ownerDetComplete,
          icon: Icons.check_circle_rounded,
          isLoading: completing,
          onPressed: alreadyDone || completing ? null : onComplete,
          height: 52,
        ),
        const SizedBox(height: AppDimensions.s10),
        SecondaryButton(
          label: t.ownerDetShare,
          leadingIcon: Icons.ios_share_rounded,
          onPressed: onShare,
        ),
      ],
    );
  }
}

/// Sticky totals dock for compact viewports: the record total plus the one
/// contextual primary. Wide viewports use the rail actions instead.
class _TotalsDock extends StatelessWidget {
  final JobCard jobCard;
  final bool completing;
  final VoidCallback onComplete;

  const _TotalsDock({
    required this.jobCard,
    required this.completing,
    required this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final colors = Theme.of(context).colorScheme;
    final formatters = AppFormatters.of(context);
    final alreadyDone = jobCard.status == JobCardStatus.completed ||
        jobCard.status == JobCardStatus.delivered;
    return SafeArea(
      top: false,
      child: Container(
        decoration: BoxDecoration(
          color: colors.surface,
          border: Border(top: BorderSide(color: colors.outlineVariant)),
        ),
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s16,
          AppDimensions.s12,
          AppDimensions.s16,
          AppDimensions.s12,
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.ownerDetTotal,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colors.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      formatAed2(formatters, jobCard.amount),
                      style: AppTextStyles.mono(color: colors.onSurface)
                          .copyWith(fontWeight: FontWeight.w800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppDimensions.s10),
            Expanded(
              child: PrimaryButton(
                label: t.ownerDetComplete,
                icon: Icons.check_circle_rounded,
                isLoading: completing,
                onPressed: alreadyDone || completing ? null : onComplete,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
