import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/advisor/domain/entities/job_card_entity.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/features/advisor/presentation/pages/advisor_vehicle_checkin_view.dart';
import 'package:staff_app/features/advisor/presentation/widgets/advisor_job_card_row.dart';

class AdvisorJobsListView extends ConsumerStatefulWidget {
  final void Function(JobCardEntity) onJobCard;
  const AdvisorJobsListView({super.key, required this.onJobCard});
  @override
  ConsumerState<AdvisorJobsListView> createState() => _AdvisorJobsListViewState();
}

class _AdvisorJobsListViewState extends ConsumerState<AdvisorJobsListView> {
  final _searchCtrl = TextEditingController();
  final _filterChips = ['All', 'In Progress', 'Completed', 'Pending', 'QC Check', 'Cancelled'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final jobCards = ref.watch(advisorRecentJobCardsProvider).value ?? const <JobCardEntity>[];
    final selectedFilter = ref.watch(_jobsFilterProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'Workshop Job Cards',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: Column(
        children: [
          // ── SEARCH PILL ──────────────────────────────────────────────────
          Container(
            color: colorScheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: TextField(
                controller: _searchCtrl,
                decoration: InputDecoration(
                  hintText: 'Search by registration, customer, or ID...',
                  hintStyle: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
                  prefixIcon: Icon(Icons.search_rounded, size: 18, color: colorScheme.onSurfaceVariant),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(fontSize: 13, color: colorScheme.onSurface),
                onChanged: (v) => ref.read(_jobsSearchProvider.notifier).state = v,
              ),
            ),
          ),

          // ── FILTER CHIPS ─────────────────────────────────────────────────
          SizedBox(
            height: 38,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: _filterChips.map((f) {
                final active = f == selectedFilter;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ref.read(_jobsFilterProvider.notifier).state = f;
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? colorScheme.primary : colorScheme.surface,
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(color: active ? Colors.transparent : colorScheme.outlineVariant),
                      ),
                      child: Text(
                        f,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w800,
                          color: active ? colorScheme.onPrimary : colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: RefreshIndicator(
              color: colorScheme.primary,
              backgroundColor: colorScheme.surface,
              onRefresh: () async => ref.read(advisorRefreshProvider.notifier).state++,
              child: _buildJobList(jobCards, selectedFilter),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobList(List<JobCardEntity> allCards, String filter) {
    final query = ref.watch(_jobsSearchProvider).toLowerCase();
    final bookings = ref.watch(advisorAssignedBookingsProvider).value ?? const <AdvisorBookingResponse>[];
    final showBookings = query.isEmpty && filter == 'All' && bookings.isNotEmpty;

    final filtered = allCards.where((jc) {
      final matchesFilter = filter == 'All' || _statusLabel(jc.status) == filter;
      final matchesSearch =
          query.isEmpty ||
          jc.id.toLowerCase().contains(query) ||
          jc.customerName.toLowerCase().contains(query) ||
          jc.vehicleInfo.toLowerCase().contains(query);
      return matchesFilter && matchesSearch;
    }).toList();

    if (filtered.isEmpty && !showBookings) {
      return const Center(
        child: EmptyState(icon: Icons.assignment_outlined, message: 'No matching job cards located'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
      itemCount: filtered.length + (showBookings ? bookings.length + 1 : 0),
      itemBuilder: (_, i) {
        if (showBookings && i == 0) {
          return _buildAssignedBookingsSection(bookings);
        }
        final index = showBookings ? i - 1 - bookings.length : i;
        if (index < 0 || index >= filtered.length) return const SizedBox.shrink();
        return AdvisorJobCardRow(jc: filtered[index], onTap: widget.onJobCard);
      },
    );
  }

  Widget _buildAssignedBookingsSection(List<AdvisorBookingResponse> bookings) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event_available_rounded, size: 18, color: colorScheme.primary),
              const SizedBox(width: 8),
              const Text('Assigned Intake Queue', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14)),
              const Spacer(),
              Text(
                '${bookings.length} Pending',
                style: TextStyle(fontWeight: FontWeight.w800, color: colorScheme.primary, fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...bookings
              .take(3)
              .map(
                (b) => ListTile(
                  dense: true,
                  title: Text('${b.serviceType} · ${b.vehicleName}'),
                  subtitle: Text('${b.customerName} · ${b.bookingDate}'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AdvisorVehicleCheckinView(
                            bookingId: '${b.id}',
                            customerName: b.customerName,
                            vehicleInfo: b.vehicleName,
                          ),
                        ),
                      );
                    },
                    child: const Text('Check In'),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  String _statusLabel(JobCardStatus s) => switch (s) {
    JobCardStatus.inProgress => 'In Progress',
    JobCardStatus.pendingApproval => 'Pending',
    JobCardStatus.completed => 'Completed',
    JobCardStatus.waitingParts => 'Waiting Parts',
    JobCardStatus.qualityCheck => 'QC Check',
    JobCardStatus.cancelled => 'Cancelled',
    JobCardStatus.pending => 'Pending',
    JobCardStatus.awaitingSupervisor => 'Awaiting Supervisor',
    JobCardStatus.vehicleReceived => 'Vehicle Received',
    JobCardStatus.waitingCustomerApproval => 'Waiting Customer Approval',
    JobCardStatus.delivered => 'Delivered',
    JobCardStatus.qualityCheckPassed => 'QC Passed',
  };
}

final _jobsSearchProvider = StateProvider<String>((ref) => '');
final _jobsFilterProvider = StateProvider<String>((ref) => 'All');
