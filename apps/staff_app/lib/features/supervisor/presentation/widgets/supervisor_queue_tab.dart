import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

/// Incoming dispatch queue for bookings and emergency breakdowns.
class SupervisorQueueTab extends ConsumerWidget {
  const SupervisorQueueTab({super.key});

  Future<void> _assign(
    BuildContext context,
    WidgetRef ref, {
    required int id,
    required bool isBooking,
    required String label,
  }) async {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final advisors = notifier.advisors;
    if (advisors.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active advisors available to assign')),
      );
      return;
    }

    int selectedId = advisors.first.id;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) {
          final theme = Theme.of(context);
          final colorScheme = theme.colorScheme;
          final textTheme = theme.textTheme;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 540),
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: colorScheme.surface,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: colorScheme.outlineVariant,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        isBooking
                            ? 'Route Booking to Service Advisor'
                            : 'Assign Breakdown to Advisor',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        label,
                        style: textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 18),
                      DropdownButtonFormField<int>(
                        initialValue: selectedId,
                        dropdownColor: colorScheme.surface,
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: colorScheme.surfaceContainerLow,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: colorScheme.outlineVariant,
                            ),
                          ),
                          labelText: 'Select Service Advisor',
                        ),
                        items: advisors.map((a) {
                          return DropdownMenuItem<int>(
                            value: a.id,
                            child: Text(a.name),
                          );
                        }).toList(),
                        onChanged: (v) =>
                            setSheetState(() => selectedId = v ?? selectedId),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () async {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                            final msg = isBooking
                                ? await notifier.assignBooking(id, selectedId)
                                : await notifier.assignBreakdown(
                                    id,
                                    selectedId,
                                  );
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(msg),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          },
                          child: Text(
                            isBooking ? 'Route to Advisor' : 'Assign Advisor',
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final bookings = notifier.bookings;
    final breakdowns = notifier.breakdowns;
    final state = ref.watch(supervisorDashboardProvider);
    final isLoading = state.isQueueLoading;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1100),
          child: RefreshIndicator(
            onRefresh: notifier.refreshQueue,
            color: colorScheme.primary,
            backgroundColor: colorScheme.surface,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                // ── Header Bar ──────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Incoming Work Queue',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Route incoming appointments and roadside breakdowns to advisors',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isLoading)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    else
                      IconButton(
                        tooltip: 'Refresh Queue',
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          notifier.refreshQueue();
                        },
                        icon: Icon(
                          Icons.refresh_rounded,
                          color: colorScheme.onSurfaceVariant,
                          size: 20,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),

                // Error notice if present
                if (state.queueError.isNotEmpty) ...[
                  _QueueNotice(
                    message: state.queueError,
                    onRetry: notifier.refreshQueue,
                  ),
                  const SizedBox(height: 16),
                ],

                // ── Content Sections ─────────────────────────────────────
                if (isWide)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Bookings column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              context,
                              icon: Icons.event_available_rounded,
                              label: 'Scheduled Appointments',
                              count: bookings.length,
                            ),
                            const SizedBox(height: 12),
                            if (bookings.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: EmptyState(
                                  icon: Icons.event_available_outlined,
                                  title: 'No pending appointments',
                                  message:
                                      'All customer bookings have been assigned.',
                                ),
                              )
                            else
                              ...bookings.map(
                                (b) => _QueueCard(
                                  icon: Icons.event_rounded,
                                  iconColor: colorScheme.primary,
                                  title: '${b.serviceType} · ${b.vehicleName}',
                                  details: [
                                    '${b.customerName} · ${b.plateNumber}',
                                    if (b.bookingDate.isNotEmpty) b.bookingDate,
                                  ],
                                  status: b.status,
                                  onAssign: () => _assign(
                                    context,
                                    ref,
                                    id: b.id,
                                    isBooking: true,
                                    label: b.serviceType,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      // Breakdowns column
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _sectionHeader(
                              context,
                              icon: Icons.emergency_rounded,
                              label: 'Emergency Breakdowns',
                              count: breakdowns.length,
                              badgeColor: colorScheme.error,
                            ),
                            const SizedBox(height: 12),
                            if (breakdowns.isEmpty)
                              const Padding(
                                padding: EdgeInsets.symmetric(vertical: 32),
                                child: EmptyState(
                                  icon: Icons.car_crash_outlined,
                                  title: 'No breakdown requests',
                                  message:
                                      'No roadside emergencies waiting for assignment.',
                                ),
                              )
                            else
                              ...breakdowns.map(
                                (b) => _QueueCard(
                                  icon: Icons.emergency_rounded,
                                  iconColor: colorScheme.error,
                                  title: b.issue,
                                  details: [
                                    '${b.customerName} · ${b.vehicleName} ${b.vehiclePlate}',
                                    if (b.location.isNotEmpty) b.location,
                                  ],
                                  status: b.status,
                                  onAssign: () => _assign(
                                    context,
                                    ref,
                                    id: b.id,
                                    isBooking: false,
                                    label: b.issue,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  )
                else ...[
                  // Mobile stacked sections
                  _sectionHeader(
                    context,
                    icon: Icons.event_available_rounded,
                    label: 'Scheduled Appointments',
                    count: bookings.length,
                  ),
                  const SizedBox(height: 10),
                  if (bookings.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: EmptyState(
                        icon: Icons.event_available_outlined,
                        title: 'No pending appointments',
                        message: 'All customer bookings have been assigned.',
                      ),
                    )
                  else
                    ...bookings.map(
                      (b) => _QueueCard(
                        icon: Icons.event_rounded,
                        iconColor: colorScheme.primary,
                        title: '${b.serviceType} · ${b.vehicleName}',
                        details: [
                          '${b.customerName} · ${b.plateNumber}',
                          if (b.bookingDate.isNotEmpty) b.bookingDate,
                        ],
                        status: b.status,
                        onAssign: () => _assign(
                          context,
                          ref,
                          id: b.id,
                          isBooking: true,
                          label: b.serviceType,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  _sectionHeader(
                    context,
                    icon: Icons.emergency_rounded,
                    label: 'Emergency Breakdowns',
                    count: breakdowns.length,
                    badgeColor: colorScheme.error,
                  ),
                  const SizedBox(height: 10),
                  if (breakdowns.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20),
                      child: EmptyState(
                        icon: Icons.car_crash_outlined,
                        title: 'No breakdown requests',
                        message:
                            'No roadside emergencies waiting for assignment.',
                      ),
                    )
                  else
                    ...breakdowns.map(
                      (b) => _QueueCard(
                        icon: Icons.emergency_rounded,
                        iconColor: colorScheme.error,
                        title: b.issue,
                        details: [
                          '${b.customerName} · ${b.vehicleName} ${b.vehiclePlate}',
                          if (b.location.isNotEmpty) b.location,
                        ],
                        status: b.status,
                        onAssign: () => _assign(
                          context,
                          ref,
                          id: b.id,
                          isBooking: false,
                          label: b.issue,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(
    BuildContext context, {
    required IconData icon,
    required String label,
    required int count,
    Color? badgeColor,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(icon, size: 16, color: badgeColor ?? colorScheme.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: (badgeColor ?? colorScheme.primary).withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor ?? colorScheme.primary,
              fontWeight: FontWeight.w800,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _QueueCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final List<String> details;
  final String status;
  final VoidCallback onAssign;

  const _QueueCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.details,
    required this.status,
    required this.onAssign,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                        ),
                        if (status.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              status.toUpperCase(),
                              style: textTheme.labelSmall?.copyWith(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ...details.map(
                      (line) => Padding(
                        padding: const EdgeInsets.only(bottom: 2),
                        child: Text(
                          line,
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 38,
            child: OutlinedButton.icon(
              onPressed: () {
                HapticFeedback.lightImpact();
                onAssign();
              },
              icon: const Icon(Icons.person_add_alt_1_rounded, size: 16),
              label: const Text('Assign Advisor'),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _QueueNotice extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _QueueNotice({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: colors.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.cloud_off_rounded,
            color: colors.onErrorContainer,
            size: 18,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: colors.onErrorContainer),
            ),
          ),
          IconButton(
            tooltip: 'Retry',
            visualDensity: VisualDensity.compact,
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
          ),
        ],
      ),
    );
  }
}
