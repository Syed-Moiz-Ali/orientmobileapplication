// ignore_for_file: non_constant_identifier_names

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/supervisor/domain/entities/supervisor_entities.dart';
import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/common/presentation/staff_shimmer_skeletons.dart';

class SupervisorDashboardTab extends ConsumerWidget {
  const SupervisorDashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final state = ref.watch(supervisorDashboardProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (state.isDashboardLoading) {
      return const SupervisorQueueSkeleton();
    }

    final bookings = notifier.bookings;
    final activeBooking = bookings.firstOrNull;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: RefreshIndicator(
        onRefresh: notifier.refreshDashboard,
        color: colorScheme.primary,
        backgroundColor: colorScheme.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // ── 1. PREMIUM SUPERVISOR COMMAND HEADER ─────────────────────
              _SupervisorPremiumHeader(
                unreadCount: notifier.unreadNotifications,
                onNotificationTap: () => notifier.loadNotifications(),
              ),
              const SizedBox(height: 24),

              // ── 2. UBER-STYLE QUICK DISPATCH SEARCH ──────────────────────
              _SupervisorSearchPill(onTap: () => notifier.selectTab(1)),
              const SizedBox(height: 24),

              // ── 3. MASONRY BENTO QUICK ACCESS MATRIX ─────────────────────
              _MasonryBentoMatrix(),
              const SizedBox(height: 28),

              // ── 4. LIVE SERVICE BAY HUD (ACTIVE RADAR) ───────────────────
              if (activeBooking != null) ...[
                _ActiveBayLiveTracker(booking: activeBooking, onTap: () => notifier.selectTab(2)),
                const SizedBox(height: 28),
              ],

              // ── 5. PHOTOGRAPHIC SPOTLIGHT HERO BANNER ────────────────────
              const _SupervisorSpotlightBanner(),
              const SizedBox(height: 32),

              // ── 6. TECHNICIAN WORKLOAD ROSTER CAROUSEL ───────────────────
              _SectionHeadingWithAction(
                title: 'Technician Workload Roster',
                actionText: 'Manage Team',
                onAction: () => context.push(AppRoutes.supervisorStaff),
              ),
              const SizedBox(height: 16),
              _AdvisorWorkloadCarousel(data: notifier.advisorJobData),
              const SizedBox(height: 32),

              // ── 7. JOB CATEGORY BREAKDOWN ────────────────────────────────
              const _SectionHeading(title: 'Active Job Card Categories'),
              const SizedBox(height: 16),
              _JobTypeShowcase(types: notifier.jobTypes),
              const SizedBox(height: 32),

              // ── 8. REVENUE TELEMETRY & SPARKLINES ────────────────────────
              _SectionHeadingWithAction(
                title: 'Revenue Telemetry',
                actionText: 'Full Breakdown',
                onAction: () => context.push(AppRoutes.supervisorReports),
              ),
              const SizedBox(height: 16),
              _RevenueGrid(metrics: notifier.revenueMetrics),
              const SizedBox(height: 16),
              const _RevenueTrendCard(),
              const SizedBox(height: 32),

              // ── 9. BOTTLENECK RADAR HUD ──────────────────────────────────
              _SectionHeadingWithAction(
                title: 'Bottleneck Status Radar',
                actionText: 'Resolve Queue',
                onAction: () => notifier.selectTab(3),
              ),
              const SizedBox(height: 16),
              _PendingGrid(statuses: notifier.pendingStatuses),
              const SizedBox(height: 96),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 1. PREMIUM COMMAND HEADER ───────────────────────────────────────────────
class _SupervisorPremiumHeader extends StatelessWidget {
  final int unreadCount;
  final VoidCallback onNotificationTap;

  const _SupervisorPremiumHeader({required this.unreadCount, required this.onNotificationTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'GARAGE ERP · COMMAND',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.primary,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Floor Supervisor',
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                  letterSpacing: -0.6,
                ),
              ),
            ],
          ),
          _PressScale(
            onTap: () {
              HapticFeedback.selectionClick();
              onNotificationTap();
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerLow,
                shape: BoxShape.circle,
                border: Border.all(color: colorScheme.outlineVariant),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(Icons.notifications_none_rounded, color: colorScheme.onSurface, size: 20),
                  if (unreadCount > 0)
                    Positioned(
                      top: 11,
                      right: 11,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: colorScheme.error,
                          shape: BoxShape.circle,
                          border: Border.all(color: colorScheme.surface, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 2. SEARCH PILL ──────────────────────────────────────────────────────────
class _SupervisorSearchPill extends StatelessWidget {
  final VoidCallback onTap;
  const _SupervisorSearchPill({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _PressScale(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outlineVariant),
            boxShadow: [
              BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6)),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.search_rounded, color: colorScheme.primary, size: 20),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Search job card, technician or bay...',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      'Assign tasks, route break-downs & inspect',
                      style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_rounded, color: colorScheme.onSurfaceVariant, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 3. MASONRY BENTO MATRIX (SECONDARY SCREEN ACCESS) ───────────────────────
class _MasonryBentoMatrix extends StatelessWidget {
  const _MasonryBentoMatrix();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                flex: 3,
                child: _BentoCard(
                  title: 'Active\nWork List',
                  subtitle: 'Real-time job logs',
                  icon: Icons.table_chart_rounded,
                  isPrimary: true,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.push(AppRoutes.supervisorJobs);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: _BentoCard(
                  title: 'Floor\nStaff',
                  subtitle: 'Specialists',
                  icon: Icons.groups_rounded,
                  isPrimary: false,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.push(AppRoutes.supervisorStaff);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _BentoCard(
                  title: 'Bay\nSchedule',
                  subtitle: 'Timelines',
                  icon: Icons.calendar_month_rounded,
                  isPrimary: false,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.push(AppRoutes.supervisorSchedule);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 3,
                child: _BentoCard(
                  title: 'Financial\nReports',
                  subtitle: 'Throughput & graphs',
                  icon: Icons.bar_chart_rounded,
                  isPrimary: false,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    context.push(AppRoutes.supervisorReports);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BentoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  const _BentoCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final bgColor = isPrimary ? colorScheme.primary : colorScheme.surface;
    final fgColor = isPrimary ? colorScheme.onPrimary : colorScheme.onSurface;

    return _PressScale(
      onTap: onTap,
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isPrimary ? Colors.transparent : colorScheme.outlineVariant),
          boxShadow: isPrimary
              ? [
                  BoxShadow(
                    color: colorScheme.primary.withValues(alpha: 0.28),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [
                  BoxShadow(
                    color: colorScheme.shadow.withValues(alpha: 0.04),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isPrimary
                        ? colorScheme.onPrimary.withValues(alpha: 0.18)
                        : colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: fgColor, size: 18),
                ),
                Icon(
                  Icons.arrow_outward_rounded,
                  color: isPrimary ? colorScheme.onPrimary.withValues(alpha: 0.6) : colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: textTheme.titleSmall?.copyWith(color: fgColor, fontWeight: FontWeight.w900, height: 1.1),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: textTheme.bodySmall?.copyWith(
                    color: isPrimary ? colorScheme.onPrimary.withValues(alpha: 0.8) : colorScheme.onSurfaceVariant,
                    fontSize: 10.5,
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

// ─── 4. LIVE SERVICE BAY HUD ─────────────────────────────────────────────────
class _ActiveBayLiveTracker extends StatelessWidget {
  final dynamic booking;
  final VoidCallback onTap;

  const _ActiveBayLiveTracker({required this.booking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _PressScale(
        onTap: () {
          HapticFeedback.lightImpact();
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(color: colorScheme.primary.withValues(alpha: 0.08), blurRadius: 20, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(color: colorScheme.primary, shape: BoxShape.circle),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'LIVE BAY 01 TELEMETRY',
                          style: textTheme.labelSmall?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.0,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'INSPECTION ACTIVE',
                    style: textTheme.labelSmall?.copyWith(color: colorScheme.secondary, fontWeight: FontWeight.w800),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(Icons.speed_rounded, color: colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${booking.serviceType} · ${booking.vehicleName}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        Text(
                          'Customer: ${booking.customerName} · Bay Assigned',
                          style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded, color: colorScheme.onSurfaceVariant),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── 5. PHOTOGRAPHIC OPERATIONAL BANNER ──────────────────────────────────────
class _SupervisorSpotlightBanner extends StatelessWidget {
  const _SupervisorSpotlightBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        height: 150,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: colorScheme.outlineVariant),
          image: const DecorationImage(
            image: NetworkImage(
              'https://images.unsplash.com/photo-1613214149922-f1809c99b414?q=80&w=800&auto=format&fit=crop',
            ),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: LinearGradient(
                    colors: [Colors.black.withValues(alpha: 0.85), Colors.black.withValues(alpha: 0.35)],
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
                      const Icon(Icons.verified_rounded, color: Colors.amberAccent, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        'PRECISION FLOOR ERP',
                        style: textTheme.labelSmall?.copyWith(
                          color: Colors.amberAccent,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Peak Diagnostic Shift\n98.4% SLA Compliance.',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, height: 1.2),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 6. TECHNICIAN ROSTER CAROUSEL ───────────────────────────────────────────
class _AdvisorWorkloadCarousel extends StatelessWidget {
  final List<AdvisorJobEntity> data;
  const _AdvisorWorkloadCarousel({required this.data});

  @override
  Widget build(BuildContext context) {
    final activeData = data.isNotEmpty
        ? data
        : [
            const AdvisorJobEntity(name: 'Marcus Vance', count: 8),
            const AdvisorJobEntity(name: 'Sarah Connor', count: 12),
            const AdvisorJobEntity(name: 'David Kim', count: 5),
            const AdvisorJobEntity(name: 'Elena Rostova', count: 11),
          ];

    return SizedBox(
      height: 140,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: activeData.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          return _AdvisorCard(
            advisor: activeData[i],
            imageUrl: i % 2 == 0
                ? 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?q=80&w=400&auto=format&fit=crop'
                : 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?q=80&w=400&auto=format&fit=crop',
          );
        },
      ),
    );
  }
}

class _AdvisorCard extends StatelessWidget {
  final AdvisorJobEntity advisor;
  final String imageUrl;

  const _AdvisorCard({required this.advisor, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      width: 200,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  advisor.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                ),
                const SizedBox(height: 2),
                Text(
                  '${advisor.count.toInt()} Active Jobs',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: colorScheme.secondary.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'ON DUTY',
                    style: textTheme.labelSmall?.copyWith(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w900,
                      fontSize: 8.5,
                    ),
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

// ─── 7. JOB TYPE SHOWCASE ────────────────────────────────────────────────────
class _JobTypeShowcase extends StatelessWidget {
  final List<JobTypeEntity> types;
  const _JobTypeShowcase({required this.types});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final activeTypes = types.isNotEmpty
        ? types
        : [
            JobTypeEntity(label: 'Full Engine MOT', count: 18, color: colorScheme.primary),
            JobTypeEntity(label: 'Brakes & Discs', count: 11, color: colorScheme.secondary),
            const JobTypeEntity(label: 'Diagnostics & ECU', count: 8, color: Color(0xFF10B981)),
            const JobTypeEntity(label: 'Emergency SOS', count: 4, color: Color(0xFFEF4444)),
          ];

    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: activeTypes.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (ctx, i) {
          final t = activeTypes[i];
          return Container(
            width: 170,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(color: t.color, borderRadius: BorderRadius.circular(3)),
                    ),
                    Text(
                      '${t.count} UNITS',
                      style: textTheme.labelSmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w800,
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: 9.5,
                      ),
                    ),
                  ],
                ),
                Text(
                  t.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── 8. REVENUE TELEMETRY GRID ───────────────────────────────────────────────
class _RevenueGrid extends StatelessWidget {
  final List<RevenueMetricEntity> metrics;
  const _RevenueGrid({required this.metrics});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < metrics.length; i += 2) {
      final left = metrics[i];
      final right = i + 1 < metrics.length ? metrics[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _RevenueMetricCard(metric: left)),
            const SizedBox(width: 12),
            right != null ? Expanded(child: _RevenueMetricCard(metric: right)) : const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < metrics.length) {
        rows.add(const SizedBox(height: 12));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: rows),
    );
  }
}

class _RevenueMetricCard extends StatelessWidget {
  final RevenueMetricEntity metric;
  const _RevenueMetricCard({required this.metric});

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(metric.icon, color: colorScheme.primary, size: 16),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  metric.change,
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w800,
                    fontSize: 10,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            metric.amount,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            metric.label,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RevenueTrendCard extends StatelessWidget {
  const _RevenueTrendCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Throughput Velocity',
                  style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                ),
                Text(
                  '+14.8% AVG',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.secondary,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 70,
              width: double.infinity,
              child: CustomPaint(
                painter: _SparklinePainter(
                  lineColor: colorScheme.primary,
                  fillColor: colorScheme.primary.withValues(alpha: 0.12),
                  points: const [0.3, 0.45, 0.4, 0.65, 0.58, 0.82, 0.95],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SparklinePainter extends CustomPainter {
  final Color lineColor;
  final Color fillColor;
  final List<double> points;

  const _SparklinePainter({required this.lineColor, required this.fillColor, required this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;

    final path = Path();
    final fillPath = Path();
    final step = size.width / (points.length - 1);

    path.moveTo(0, size.height * (1.0 - points.first));
    fillPath.moveTo(0, size.height);
    fillPath.lineTo(0, size.height * (1.0 - points.first));

    for (int i = 1; i < points.length; i++) {
      final x = i * step;
      final y = size.height * (1.0 - points[i]);
      final prevX = (i - 1) * step;
      final prevY = size.height * (1.0 - points[i - 1]);

      final controlX = (prevX + x) / 2;
      path.cubicTo(controlX, prevY, controlX, y, x, y);
      fillPath.cubicTo(controlX, prevY, controlX, y, x, y);
    }

    fillPath.lineTo(size.width, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = lineColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ─── 9. PENDING STATUS RADAR ─────────────────────────────────────────────────
class _PendingGrid extends StatelessWidget {
  final List<PendingStatusEntity> statuses;
  const _PendingGrid({required this.statuses});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < statuses.length; i += 2) {
      final left = statuses[i];
      final right = i + 1 < statuses.length ? statuses[i + 1] : null;
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _PendingCard(status: left)),
            const SizedBox(width: 12),
            right != null ? Expanded(child: _PendingCard(status: right)) : const Expanded(child: SizedBox()),
          ],
        ),
      );
      if (i + 2 < statuses.length) {
        rows.add(const SizedBox(height: 12));
      }
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(children: rows),
    );
  }
}

class _PendingCard extends StatelessWidget {
  final PendingStatusEntity status;
  const _PendingCard({required this.status});

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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: status.color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(status.icon, color: status.color, size: 16),
          ),
          const SizedBox(height: 10),
          Text(
            status.count,
            style: textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            status.label,
            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 11),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── HEADINGS & MOTION HELPERS ───────────────────────────────────────────────
class _SectionHeading extends StatelessWidget {
  final String title;
  final String? badge;
  const _SectionHeading({required this.title, this.badge});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
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
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badge!,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w800,
                  fontSize: 9,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionHeadingWithAction extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onAction;

  const _SectionHeadingWithAction({required this.title, required this.actionText, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -0.4,
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onAction();
            },
            child: Text(
              actionText,
              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressScale({required this.child, this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic, reverseCurve: Curves.easeInCubic));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
