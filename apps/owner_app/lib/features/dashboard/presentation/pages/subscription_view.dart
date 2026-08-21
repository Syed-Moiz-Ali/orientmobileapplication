import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/subscription_providers.dart';

class SubscriptionView extends ConsumerWidget {
  const SubscriptionView({super.key});

  static const _plans = [
    ('starter', 'Starter Tier', 'For single-branch workshops & garages', 'AED 499 / mo'),
    ('pro', 'Professional Hub', 'Multi-branch operations + CRM + inventory', 'AED 1,299 / mo'),
    ('enterprise', 'Enterprise Fleet', 'Custom integrations, SSO, SLAs, dedicated AM', 'AED 2,499 / mo'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(subscriptionProvider);
    final notifier = ref.read(subscriptionProvider.notifier);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Subscription & Billing',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: notifier.load,
          ),
        ],
      ),
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              children: [
                AppCard(
                  padding: const EdgeInsets.all(20),
                  borderRadius: AppDimensions.r24,
                  color: colorScheme.surface,
                  borderColor: colorScheme.outlineVariant,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'CURRENT TIER',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurfaceVariant,
                              letterSpacing: 1.0,
                            ),
                          ),
                          StatusPill(
                            label: state.status.toUpperCase(),
                            showDot: true,
                            bg: const Color(0xFF10B981).withValues(alpha: 0.12),
                            fg: const Color(0xFF10B981),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        state.plan.toUpperCase(),
                        style: textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: colorScheme.primary,
                          letterSpacing: -0.5,
                        ),
                      ),
                      if (state.renewsAt.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Next billing cycle renewal: ${state.renewsAt}',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'AVAILABLE WORKSHOP PLANS',
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurfaceVariant,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 12),
                ..._plans.map((p) {
                  final selected = state.plan == p.$1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: AppCard(
                      padding: const EdgeInsets.all(18),
                      borderRadius: AppDimensions.r20,
                      color: selected
                          ? colorScheme.primary.withValues(alpha: 0.06)
                          : colorScheme.surface,
                      borderColor: selected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      p.$2,
                                      style: textTheme.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w900,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      p.$4,
                                      style: textTheme.labelSmall?.copyWith(
                                        color: colorScheme.primary,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  p.$3,
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (selected)
                            Icon(Icons.check_circle_rounded, color: colorScheme.primary, size: 24)
                          else
                            OutlinedButton(
                              onPressed: () async {
                                final err = await notifier.setPlan(p.$1);
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(err ?? 'Plan updated to ${p.$2}'),
                                  ));
                                }
                              },
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(AppDimensions.r10),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              ),
                              child: const Text('Select', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                            ),
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
    );
  }
}
