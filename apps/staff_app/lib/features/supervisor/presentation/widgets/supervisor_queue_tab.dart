import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

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
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No active advisors available to assign')));
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

          return Padding(
            padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 38,
                      height: 4,
                      decoration: BoxDecoration(
                        color: colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isBooking ? 'Route Booking to Service Advisor' : 'Dispatch Breakdown Unit',
                    style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.onSurface),
                  ),
                  const SizedBox(height: 4),
                  Text(label, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<int>(
                    initialValue: selectedId,
                    dropdownColor: colorScheme.surface,
                    style: TextStyle(color: colorScheme.onSurface, fontSize: 14),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: colorScheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide(color: colorScheme.outlineVariant),
                      ),
                      labelText: 'Select Advisor',
                    ),
                    items: advisors.map((a) {
                      return DropdownMenuItem<int>(value: a.id, child: Text(a.name));
                    }).toList(),
                    onChanged: (v) => setSheetState(() => selectedId = v ?? selectedId),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                        minimumSize: const Size(0, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () async {
                        HapticFeedback.lightImpact();
                        Navigator.pop(context);
                        final msg = isBooking
                            ? await notifier.assignBooking(id, selectedId)
                            : await notifier.assignBreakdown(id, selectedId);
                        if (context.mounted) {
                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));
                        }
                      },
                      child: Text(
                        isBooking ? 'Confirm Route' : 'Dispatch Squad',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
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
    final isLoading = ref.watch(supervisorDashboardProvider).isQueueLoading;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: notifier.refreshQueue,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            Row(
              children: [
                Text(
                  'Incoming Dispatch Queue',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    color: colorScheme.onSurface,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                if (isLoading)
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary),
                  )
                else
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      notifier.refreshQueue();
                    },
                    icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurfaceVariant, size: 20),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            _sectionTitle(context, 'Appointments', bookings.length),
            const SizedBox(height: 10),
            if (bookings.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(icon: Icons.event_available_outlined, message: 'No unassigned appointments'),
              )
            else
              ...bookings.map(
                (b) => _QueueCard(
                  icon: Icons.event_rounded,
                  iconColor: colorScheme.primary,
                  title: '${b.serviceType} · ${b.vehicleName}',
                  subtitle: '${b.customerName} · ${b.plateNumber}\n${b.bookingDate}',
                  trailingLabel: b.status,
                  bookingDateStr: b.bookingDate,
                  isNew: b.status.toLowerCase() == 'pending',
                  onAssign: () => _assign(context, ref, id: b.id, isBooking: true, label: b.serviceType),
                ),
              ),

            const SizedBox(height: 24),
            _sectionTitle(context, 'Breakdown Radar', breakdowns.length),
            const SizedBox(height: 10),
            if (breakdowns.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: EmptyState(icon: Icons.emergency_outlined, message: 'No emergency breakdown signals'),
              )
            else
              ...breakdowns.map(
                (b) => _QueueCard(
                  icon: Icons.emergency_rounded,
                  iconColor: colorScheme.error,
                  title: b.issue,
                  subtitle: '${b.customerName} · ${b.vehicleName} ${b.vehiclePlate}\n${b.location}',
                  trailingLabel: b.status,
                  bookingDateStr: '',
                  isNew: b.status.toLowerCase() == 'pending',
                  onAssign: () => _assign(context, ref, id: b.id, isBooking: false, label: b.issue),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(BuildContext context, String label, int count) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(label, style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
          decoration: BoxDecoration(color: colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
          child: Text(
            '$count',
            style: theme.textTheme.labelSmall?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w900,
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
  final String subtitle;
  final String trailingLabel;
  final VoidCallback onAssign;
  final String? bookingDateStr;
  final bool isNew;

  const _QueueCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailingLabel,
    required this.onAssign,
    this.bookingDateStr,
    this.isNew = false,
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 14, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 3),
                Text(subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () {
              HapticFeedback.lightImpact();
              onAssign();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              minimumSize: const Size(0, 38),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Assign', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
          ),
        ],
      ),
    );
  }
}
