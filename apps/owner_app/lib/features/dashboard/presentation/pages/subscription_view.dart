import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/subscription_providers.dart';

/// P3 (audit): SaaS subscription screen — current plan + plan switcher.
class SubscriptionView extends ConsumerWidget {
  const SubscriptionView({super.key});

  static const _plans = [
    ('starter', 'Starter', 'For single-branch workshops'),
    ('pro', 'Pro', 'Multi-branch + CRM + inventory'),
    ('enterprise', 'Enterprise', 'SSO, SLAs, dedicated support'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(subscriptionProvider);
    final notifier = ref.read(subscriptionProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Subscription',
          style: TextStyle(color: AppColors.gray900, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.gray700),
            onPressed: notifier.load,
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.navy, AppColors.accent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('CURRENT PLAN',
                          style: TextStyle(color: Colors.white70, fontSize: 11, letterSpacing: 1)),
                      const SizedBox(height: 6),
                      Text(state.plan.toUpperCase(),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 4),
                      Text(
                        'Status: ${state.status.toUpperCase()}'
                        '${state.renewsAt.isNotEmpty ? '  ·  Renews: ${state.renewsAt}' : ''}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text('Choose a plan',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.gray900)),
                const SizedBox(height: 10),
                ..._plans.map((p) {
                  final selected = state.plan == p.$1;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: selected ? const Color(0xFFEFF6FF) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected ? AppColors.primary : AppColors.gray200,
                          width: selected ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(p.$2,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.gray900)),
                                const SizedBox(height: 2),
                                Text(p.$3, style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
                              ],
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22),
                        ],
                      ),
                    ),
                  );
                }),
                const SizedBox(height: 8),
                const Text(
                  'Billing/payment integration arrives with the billing module; the plan state is recorded now.',
                  style: TextStyle(fontSize: 11, color: AppColors.gray400),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () async {
                final current = state.plan;
                final chosen = await showModalBottomSheet<String>(
                  context: context,
                  builder: (ctx) => SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: _plans
                          .where((p) => p.$1 != current)
                          .map((p) => ListTile(
                                title: Text('${p.$2} (${p.$1})'),
                                subtitle: Text(p.$3),
                                onTap: () => Navigator.pop(ctx, p.$1),
                              ))
                          .toList(),
                    ),
                  ),
                );
                if (chosen != null) {
                  final err = await notifier.setPlan(chosen);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(err ?? 'Plan updated to $chosen'),
                    ));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Change Plan', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}
