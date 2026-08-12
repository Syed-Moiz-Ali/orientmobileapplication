import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

// FE-FIX (frontend pass): was a flat "Today's Schedule" of every assigned
// job. Now a real day-scoped schedule: 7-day strip + the actual bookings
// (from the live queue, grouped by the backend dateKey) + assigned jobs.
class SupervisorScheduleTab extends ConsumerStatefulWidget {
  const SupervisorScheduleTab({super.key});

  @override
  ConsumerState<SupervisorScheduleTab> createState() =>
      _SupervisorScheduleTabState();
}

class _SupervisorScheduleTabState extends ConsumerState<SupervisorScheduleTab> {
  DateTime _selectedDay = DateTime.now();

  String _iso(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _sameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final bookings = notifier.bookings;
    final jobs = notifier.jobs;

    final today = DateTime.now();
    final days = List.generate(7, (i) => today.add(Duration(days: i)));

    final dayBookings = bookings.where((b) => b.dateKey == _iso(_selectedDay)).toList();
    final dayJobs = jobs.where((j) => j.dateAssigned.contains(_iso(_selectedDay))).toList();
    final isToday = _sameDay(_selectedDay, today);

    return RefreshIndicator(
      color: AppColors.accent,
      onRefresh: notifier.refreshQueue,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppDimensions.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                  'Schedule',
                  style: AppTextStyles.title(
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 74,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: days.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final d = days[i];
                  final sel = _sameDay(d, _selectedDay);
                  final count = bookings.where((b) => b.dateKey == _iso(d)).length;
                  final labels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = d),
                    child: Container(
                      width: 56,
                      decoration: BoxDecoration(
                        color: sel ? AppColors.accent : AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: sel ? AppColors.accent : AppColors.border,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            labels[d.weekday - 1],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: sel ? Colors.white : AppColors.text3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${d.day}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: sel ? Colors.white : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            count > 0 ? '$count' : '',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: sel ? Colors.white70 : AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                _summaryChip('${dayBookings.length} bookings', AppColors.accent),
                const SizedBox(width: 8),
                _summaryChip('${dayJobs.length} jobs assigned', AppColors.info),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              isToday
                  ? "Today's bookings"
                  : 'Bookings — ${_selectedDay.day} ${_monthName(_selectedDay.month)}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (dayBookings.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 28),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.border),
                ),
                child: const Center(
                  child: Text(
                    'No bookings for this day',
                    style: TextStyle(fontSize: 13, color: AppColors.text3),
                  ),
                ),
              )
            else
              ...dayBookings.map((b) => _bookingTile(b)),
            const SizedBox(height: 20),
            Text(
              'Assigned work',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            if (dayJobs.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'No jobs assigned on this day',
                  style: TextStyle(fontSize: 13, color: AppColors.text3),
                ),
              )
            else
              ...dayJobs.map((j) => _jobTile(j)),
          ],
        ),
      ),
    );
  }

  String _monthName(int m) =>
      const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'][m - 1];

  Widget _summaryChip(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      );

  Widget _bookingTile(BookingQueueResponse b) {
    final pending = b.status == 'pending';
    final clr = pending ? AppColors.warning : AppColors.accent;
    final bg = pending ? AppColors.warningBg : AppColors.accent.withValues(alpha: 0.12);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.calendar_month_rounded, color: clr, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      b.bookingRef,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: bg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        b.status == 'pending' ? 'PENDING' : 'CONFIRMED',
                        style: TextStyle(color: clr, fontSize: 9, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${b.serviceType}  \u00b7  ${b.vehicleName}',
                  style: const TextStyle(fontSize: 12, color: AppColors.text3),
                ),
                const SizedBox(height: 2),
                Text(
                  '${b.customerName}  \u00b7  ${b.bookingDate}',
                  style: const TextStyle(fontSize: 11, color: AppColors.text3),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobTile(dynamic j) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: j.status == 'Completed'
                    ? AppColors.success
                    : j.status == 'In Progress'
                        ? AppColors.accent
                        : AppColors.warning,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    j.jobCard,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${j.customer}  \u00b7  ${j.vehicle}',
                    style: const TextStyle(fontSize: 12, color: AppColors.text3),
                  ),
                ],
              ),
            ),
            Text(
              j.status,
              style: const TextStyle(fontSize: 11, color: AppColors.text3),
            ),
          ],
        ),
      );
}
