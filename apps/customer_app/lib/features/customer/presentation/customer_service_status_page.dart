import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';

import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/widgets/customer_service_status_tab.dart';

/// Contextual Customer Service Status.
///
/// Status is the detailed view of one active workshop job, so it is a pushed
/// page rather than a permanent destination: it keeps its own back affordance
/// and never pretends one of the five primary destinations is selected, and it
/// shows no bottom navigation. The tracking experience itself is the canonical
/// [CustomerServiceStatusTab] — nothing about it is duplicated here.
class CustomerServiceStatusPage extends StatelessWidget {
  const CustomerServiceStatusPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: 'Service status',
              onBack: () {
                // Reached from the workspace → return to it. Reached directly
                // from a deep link (nothing to pop) → go to the workspace
                // instead of stranding the user on a page with no way out.
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(AppRoutes.customerDashboard);
                }
              },
            ),
            Divider(height: 1, color: theme.colorScheme.outlineVariant),
            const Expanded(child: CustomerServiceStatusTab(showTitle: false)),
          ],
        ),
      ),
    );
  }
}
