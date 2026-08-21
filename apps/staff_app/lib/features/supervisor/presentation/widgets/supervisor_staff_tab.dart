import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';

class SupervisorStaffTab extends ConsumerWidget {
  const SupervisorStaffTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final technicians = notifier.technicians;
    final departments = notifier.departments;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 1. ROSTER BANNER HERO ───────────────────────────────────────
            _StaffHeroBanner(totalTechs: technicians.length),
            const SizedBox(height: 24),

            // ── 2. ACTIVE TECHNICIANS LIST ──────────────────────────────────
            _SectionHeadingWithBadge(title: 'Floor Technicians', badge: '${technicians.length} ACTIVE'),
            const SizedBox(height: 14),
            if (technicians.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 32),
                child: EmptyState(icon: Icons.badge_outlined, message: 'No technicians assigned to the current shift'),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: technicians.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (context, i) {
                  final techName = technicians[i];
                  final dept = departments.isNotEmpty ? departments[i % departments.length] : 'Diagnostics';

                  return _TechnicianRosterCard(
                    name: techName,
                    department: dept,
                    activeJobs: (i * 3 % 7) + 1,
                    rating: 4.8 + (i % 3) * 0.1,
                  );
                },
              ),
            const SizedBox(height: 28),

            // ── 3. DEPARTMENT WORKLOADS ────────────────────────────────────
            const _SectionHeadingWithBadge(title: 'Bay Workload by Unit', badge: 'CAPACITY'),
            const SizedBox(height: 14),
            ...departments.map((dept) => _DepartmentCapacityCard(department: dept)),
          ],
        ),
      ),
    );
  }
}

class _StaffHeroBanner extends StatelessWidget {
  final int totalTechs;
  const _StaffHeroBanner({required this.totalTechs});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      height: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: colorScheme.outlineVariant),
        image: const DecorationImage(
          image: NetworkImage(
            'https://images.unsplash.com/photo-1581092160607-ee22621dd758?q=80&w=800&auto=format&fit=crop',
          ),
          fit: BoxFit.cover,
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [Colors.black.withValues(alpha: 0.88), Colors.black.withValues(alpha: 0.4)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_alt_rounded, color: Colors.amberAccent, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'WORKFORCE COMMAND',
                      style: textTheme.labelSmall?.copyWith(
                        color: Colors.amberAccent,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '$totalTechs Specialists on Shift',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
                    fontSize: 20,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '100% station utilization across all bays',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.75),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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

class _TechnicianRosterCard extends StatelessWidget {
  final String name;
  final String department;
  final int activeJobs;
  final double rating;

  const _TechnicianRosterCard({
    required this.name,
    required this.department,
    required this.activeJobs,
    required this.rating,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: colorScheme.surfaceContainerHighest,
            child: Text(
              name.isNotEmpty ? name[0] : 'T',
              style: textTheme.titleSmall?.copyWith(color: colorScheme.primary, fontWeight: FontWeight.w900),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  '$department · $activeJobs tasks active',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 12),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Color(0xFF10B981), size: 6),
                    SizedBox(width: 4),
                    Text(
                      'ON FLOOR',
                      style: TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 9.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.star_rounded, color: Colors.amber.shade600, size: 14),
                  const SizedBox(width: 2),
                  Text(
                    rating.toStringAsFixed(1),
                    style: textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DepartmentCapacityCard extends StatelessWidget {
  final String department;
  const _DepartmentCapacityCard({required this.department});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.precision_manufacturing_rounded, color: colorScheme.primary, size: 18),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  department,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  'Bay Efficiency 94%',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios_rounded, color: colorScheme.onSurfaceVariant, size: 14),
        ],
      ),
    );
  }
}

class _SectionHeadingWithBadge extends StatelessWidget {
  final String title;
  final String? badge;

  const _SectionHeadingWithBadge({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
        if (badge != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge!,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w900,
                fontSize: 9,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
