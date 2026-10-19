import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/subscription_providers.dart';
import 'package:owner_app/l10n/gen/owner_localizations.dart';

/// Plan catalog copy. Tier ids are the frozen `setPlan` contract values;
/// only the rendered names change per locale.
class _Plan {
  final String id;
  final String Function(OwnerLocalizations t) name;
  final String Function(OwnerLocalizations t) hint;
  final String Function(OwnerLocalizations t) price;

  const _Plan({
    required this.id,
    required this.name,
    required this.hint,
    required this.price,
  });
}

final _plans = <_Plan>[
  _Plan(
    id: 'starter',
    name: (t) => t.ownerSbStarter,
    hint: (t) => t.ownerSbStarterHint,
    price: (t) => t.ownerSbStarterPrice,
  ),
  _Plan(
    id: 'pro',
    name: (t) => t.ownerSbPro,
    hint: (t) => t.ownerSbProHint,
    price: (t) => t.ownerSbProPrice,
  ),
  _Plan(
    id: 'enterprise',
    name: (t) => t.ownerSbEnterprise,
    hint: (t) => t.ownerSbEnterpriseHint,
    price: (t) => t.ownerSbEnterprisePrice,
  ),
];

String _planName(OwnerLocalizations t, String id) =>
    _plans.where((p) => p.id == id).firstOrNull?.name(t) ?? id;

/// Subscription (O15): current-tier hero with renewal line plus the plan
/// catalog over the frozen `setPlan` contract. There is no external manage
/// route — the in-app plan switch (with themed result toasts) is the real
/// management action.
class SubscriptionView extends ConsumerWidget {
  const SubscriptionView({super.key});

  void _toast(BuildContext context, String msg, {required bool ok}) {
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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final state = ref.watch(subscriptionProvider);
    final notifier = ref.read(subscriptionProvider.notifier);

    final wide = context.adaptive.pick(
      compact: false,
      medium: false,
      expanded: true,
      large: true,
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: WorkspaceAppBar(
        title: t.ownerSbTitle,
        showBack: true,
        showOfflineStatus: true,
        actions: [
          IconButton(
            tooltip: MaterialLocalizations.of(context)
                .refreshIndicatorSemanticLabel,
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              HapticFeedback.selectionClick();
              notifier.load();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const AppSkeleton.page()
            : AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppCard.standard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  t.ownerSbCurrent.toUpperCase(),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colors.onSurfaceVariant,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ),
                              StatusPill.success(
                                state.status.toUpperCase(),
                                showDot: true,
                              ),
                            ],
                          ),
                          const SizedBox(height: AppDimensions.s10),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              _planName(t, state.plan).toUpperCase(),
                              style: theme.textTheme.headlineMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: colors.primary,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          if (state.renewsAt.isNotEmpty) ...[
                            const SizedBox(height: AppDimensions.s6),
                            Directionality(
                              textDirection: TextDirection.ltr,
                              child: Text(
                                t.ownerSbRenews(state.renewsAt),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colors.onSurfaceVariant,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppDimensions.s24),
                    Semantics(
                      header: true,
                      child: SectionHeader(title: t.ownerSbPlans),
                    ),
                    if (wide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          for (var i = 0; i < _plans.length; i++) ...[
                            if (i > 0)
                              const SizedBox(width: AppDimensions.s12),
                            Expanded(
                              child: _PlanCard(
                                plan: _plans[i],
                                selected:
                                    state.plan == _plans[i].id,
                                onSelect: () async {
                                  HapticFeedback.selectionClick();
                                  final err = await notifier
                                      .setPlan(_plans[i].id);
                                  if (!context.mounted) return;
                                  _toast(
                                    context,
                                    err ?? t.ownerSbChanged,
                                    ok: err == null,
                                  );
                                },
                              ),
                            ),
                          ],
                        ],
                      )
                    else
                      for (final plan in _plans) ...[
                        _PlanCard(
                          plan: plan,
                          selected: state.plan == plan.id,
                          onSelect: () async {
                            HapticFeedback.selectionClick();
                            final err =
                                await notifier.setPlan(plan.id);
                            if (!context.mounted) return;
                            _toast(
                              context,
                              err ?? t.ownerSbChanged,
                              ok: err == null,
                            );
                          },
                        ),
                        const SizedBox(height: AppDimensions.s12),
                      ],
                    const SizedBox(height: AppDimensions.s32),
                  ],
                ),
              ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final _Plan plan;
  final bool selected;
  final VoidCallback onSelect;

  const _PlanCard({
    required this.plan,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final t = OwnerLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    return AppCard(
      padding: const EdgeInsets.all(AppDimensions.s16),
      borderRadius: AppDimensions.radiusCard,
      color: selected
          ? colors.primary.withValues(alpha: 0.06)
          : colors.surface,
      borderColor:
          selected ? colors.primary : colors.outlineVariant,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  plan.name(t),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: colors.onSurface,
                  ),
                ),
              ),
              if (selected)
                Icon(
                  Icons.check_circle_rounded,
                  color: colors.primary,
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 2),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              plan.price(t),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            plan.hint(t),
            style: theme.textTheme.bodySmall?.copyWith(
              color: colors.onSurfaceVariant,
            ),
          ),
          if (!selected) ...[
            const SizedBox(height: AppDimensions.s12),
            SizedBox(
              height: AppDimensions.touchTarget,
              child: OutlinedButton(
                onPressed: onSelect,
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.radiusButton,
                    ),
                  ),
                ),
                child: Text(
                  t.ownerSbSelect,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ] else ...[
            const SizedBox(height: AppDimensions.s8),
            StatusPill.neutral(t.ownerSbCurrentPlan),
          ],
        ],
      ),
    );
  }
}
