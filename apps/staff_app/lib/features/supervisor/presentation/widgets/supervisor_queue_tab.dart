import 'package:flutter/material.dart';
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
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(AppDimensions.r24),
              ),
            ),
            padding: const EdgeInsets.all(AppDimensions.s16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  isBooking
                      ? 'Assign booking to advisor'
                      : 'Dispatch breakdown to advisor',
                  style: AppTextStyles.title(
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  style: const TextStyle(fontSize: 13, color: AppColors.text3),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<int>(
                  initialValue: selectedId,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.primaryBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r12),
                      borderSide: BorderSide.none,
                    ),
                    labelText: 'Advisor',
                  ),
                  items: advisors.map((a) {
                    return DropdownMenuItem<int>(
                      value: a.id,
                      child: Text(
                        a.name,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (v) =>
                      setSheetState(() => selectedId = v ?? selectedId),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.r12),
                      ),
                    ),
                    onPressed: () async {
                      Navigator.pop(context);
                      final msg = isBooking
                          ? await notifier.assignBooking(id, selectedId)
                          : await notifier.assignBreakdown(id, selectedId);
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
                      isBooking ? 'Assign' : 'Dispatch',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final bookings = notifier.bookings;
    final breakdowns = notifier.breakdowns;
    final isLoading = ref.watch(supervisorDashboardProvider).isQueueLoading;

    return RefreshIndicator(
      onRefresh: notifier.refreshQueue,
      child: ListView(
        padding: const EdgeInsets.all(AppDimensions.s16),
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 20,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Bookings & Breakdowns',
                style: AppTextStyles.title(
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                IconButton(
                  onPressed: notifier.refreshQueue,
                  icon: const Icon(
                    Icons.refresh_rounded,
                    color: AppColors.text3,
                    size: 20,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Route incoming requests to an advisor',
            style: TextStyle(fontSize: 13, color: AppColors.text3),
          ),
          const SizedBox(height: 16),

          _sectionTitle('Appointments', bookings.length),
          const SizedBox(height: 8),
          if (bookings.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                icon: Icons.event_available_outlined,
                message: 'No unassigned bookings',
              ),
            )
          else
            ...bookings.map(
              (b) => _QueueCard(
                icon: Icons.event_rounded,
                iconColor: const Color(0xFF1F6FEB),
                title: '${b.serviceType} · ${b.vehicleName}',
                subtitle:
                    '${b.customerName} · ${b.plateNumber}\n${b.bookingDate}',
                trailingLabel: b.status,
                bookingDateStr: b.bookingDate,
                isNew: b.status.toLowerCase() == 'pending',
                onAssign: () => _assign(
                  context,
                  ref,
                  id: b.id,
                  isBooking: true,
                  label: b.serviceType,
                ),
              ),
            ),

          const SizedBox(height: 20),
          _sectionTitle('Breakdowns', breakdowns.length),
          const SizedBox(height: 8),
          if (breakdowns.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                icon: Icons.emergency_outlined,
                message: 'No unassigned breakdowns',
              ),
            )
          else
            ...breakdowns.map(
              (b) => _QueueCard(
                icon: Icons.emergency_rounded,
                iconColor: const Color(0xFFDA3633),
                title: b.issue,
                subtitle:
                    '${b.customerName} · ${b.vehicleName} ${b.vehiclePlate}\n${b.location}',
                trailingLabel: b.status,
                bookingDateStr: '',
                isNew: b.status.toLowerCase() == 'pending',
                onAssign: () => _assign(
                  context,
                  ref,
                  id: b.id,
                  isBooking: false,
                  label: b.issue,
                ),
              ),
            ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _sectionTitle(String label, int count) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primaryBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              color: AppColors.accent,
              fontWeight: FontWeight.w800,
              fontSize: 12,
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
  final String? bookingDateStr; // Added for SLA timer
  final bool isNew; // Added for unread indicator

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
    Widget iconWidget = Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.r12),
      ),
      child: Icon(icon, color: iconColor, size: 22),
    );

    if (isNew) {
      iconWidget = Stack(
        clipBehavior: Clip.none,
        children: [
          iconWidget,
          Positioned(
            top: -2,
            right: -2,
            child: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: const Color(0xFF1F6FEB),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.surface, width: 2),
              ),
            ),
          ),
        ],
      );
    }

    Widget slaWidget = const SizedBox.shrink();
    if (bookingDateStr != null) {
      final date = DateTime.tryParse(bookingDateStr!) ?? DateTime.now();
      final diff = DateTime.now().difference(date);
      final hours = diff.inHours;
      final minutes = diff.inMinutes.remainder(60);

      Color slaColor = AppColors.success;
      if (hours >= 3) {
        slaColor = AppColors.danger;
      } else if (hours >= 1) {
        slaColor = AppColors.warning;
      }

      slaWidget = Padding(
        padding: const EdgeInsets.only(top: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 10, color: slaColor),
            const SizedBox(width: 4),
            Text(
              'Waiting ${hours}h ${minutes}m',
              style: TextStyle(
                color: slaColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppCard(
        padding: const EdgeInsets.all(AppDimensions.s16),
        child: Row(
          children: [
            iconWidget,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.text3,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusPill(label: trailingLabel),
                if (bookingDateStr != null) slaWidget,
                const SizedBox(height: 8),
                SizedBox(
                  height: 32,
                  child: OutlinedButton(
                    onPressed: onAssign,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppDimensions.r10),
                      ),
                    ),
                    child: const Text(
                      'Assign',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
