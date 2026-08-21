import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'inspection_provider.dart';

class ChooseInspectionView extends ConsumerWidget {
  final VoidCallback onSelect;
  final VoidCallback onSkip;
  final VoidCallback onBack;

  const ChooseInspectionView({
    super.key,
    required this.onSelect,
    required this.onSkip,
    required this.onBack,
  });

  void _startInspection(BuildContext context, WidgetRef ref, {required String templateName}) {
    HapticFeedback.mediumImpact();
    ref.read(inspectionProvider.notifier).reset();
    final cb = InspectionCallbacks(
      onBack: () => context.pop(),
      onSaveDraft: () {
        context.pop();
        onSelect();
      },
      onPreview: () {
        context.push(
          AppRoutes.inspectionPreview,
          extra: {
            'onBack': () {
              context.pop();
              onSelect();
            },
          },
        );
      },
    );
    context.push(AppRoutes.inspectionSheet, extra: cb);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: onBack,
        ),
        title: Text(
          'Select Inspection Template',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              context.push(
                AppRoutes.repairOrder,
                extra: {'onBack': () => context.pop(), 'fromInspection': true},
              );
            },
            child: Text(
              'Skip Inspection',
              style: TextStyle(
                color: colorScheme.primary,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: AppResponsivePage(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              // ── HERO HEADER BANNER ─────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      colorScheme.primaryContainer.withValues(alpha: 0.5),
                      colorScheme.surfaceContainerLow,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.r24),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppDimensions.r16),
                      ),
                      child: Icon(
                        Icons.fact_check_outlined,
                        color: colorScheme.primary,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Digital Vehicle Health Check',
                            style: textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Perform multi-point checks with photo evidence, voice memos, and instant estimate generation.',
                            style: textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              Text(
                'Available Checkpoint Sheets',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 14),

              // ── TEMPLATE 1: MASTER 24-POINT DIGITAL CHECK ──────────────────
              _InspectionTemplateCard(
                title: 'Comprehensive 24-Point Health Check',
                subtitle: 'Full under-hood, brakes, suspension, battery, tires & exterior inspection',
                sectionsCount: 4,
                checkpointsCount: 24,
                estimatedMinutes: 15,
                isRecommended: true,
                badge: 'STANDARD OEM',
                icon: Icons.checklist_rtl_rounded,
                colorScheme: colorScheme,
                textTheme: textTheme,
                onTap: () => _startInspection(context, ref, templateName: 'Comprehensive 24-Point'),
              ),
              const SizedBox(height: 16),

              // ── TEMPLATE 2: EXPRESS BAY SCAN ───────────────────────────────
              _InspectionTemplateCard(
                title: 'Express Bay Safety Scan',
                subtitle: 'Rapid fluid levels, tire pressure, lighting, wiper blades & battery voltage check',
                sectionsCount: 2,
                checkpointsCount: 10,
                estimatedMinutes: 5,
                isRecommended: false,
                badge: 'QUICK INTAKE',
                icon: Icons.speed_rounded,
                colorScheme: colorScheme,
                textTheme: textTheme,
                onTap: () => _startInspection(context, ref, templateName: 'Express Bay Safety Scan'),
              ),
              const SizedBox(height: 16),

              // ── TEMPLATE 3: BRAKES & CHASSIS DIAGNOSTIC ─────────────────────
              _InspectionTemplateCard(
                title: 'Brake, Steering & Suspension Audit',
                subtitle: 'Pad/rotor depth measurements, shock absorber leak check, alignment & bushings',
                sectionsCount: 3,
                checkpointsCount: 14,
                estimatedMinutes: 10,
                isRecommended: false,
                badge: 'MECHANICAL',
                icon: Icons.car_repair_rounded,
                colorScheme: colorScheme,
                textTheme: textTheme,
                onTap: () => _startInspection(context, ref, templateName: 'Brake & Suspension Audit'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _InspectionTemplateCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int sectionsCount;
  final int checkpointsCount;
  final int estimatedMinutes;
  final bool isRecommended;
  final String badge;
  final IconData icon;
  final ColorScheme colorScheme;
  final TextTheme textTheme;
  final VoidCallback onTap;

  const _InspectionTemplateCard({
    required this.title,
    required this.subtitle,
    required this.sectionsCount,
    required this.checkpointsCount,
    required this.estimatedMinutes,
    required this.isRecommended,
    required this.badge,
    required this.icon,
    required this.colorScheme,
    required this.textTheme,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      borderRadius: AppDimensions.r24,
      color: colorScheme.surface,
      borderColor: isRecommended ? colorScheme.primary.withValues(alpha: 0.5) : colorScheme.outlineVariant,
      padding: const EdgeInsets.all(20),
      boxShadow: [
        BoxShadow(
          color: isRecommended
              ? colorScheme.primary.withValues(alpha: 0.08)
              : colorScheme.shadow.withValues(alpha: 0.04),
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isRecommended
                      ? colorScheme.primary.withValues(alpha: 0.12)
                      : colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppDimensions.r14),
                ),
                child: Icon(
                  icon,
                  color: isRecommended ? colorScheme.primary : colorScheme.onSurfaceVariant,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        StatusPill(
                          label: badge,
                          bg: isRecommended
                              ? colorScheme.primary.withValues(alpha: 0.12)
                              : colorScheme.surfaceContainerHighest,
                          fg: isRecommended ? colorScheme.primary : colorScheme.onSurfaceVariant,
                        ),
                        if (isRecommended) ...[
                          const SizedBox(width: 8),
                          StatusPill(
                            label: 'POPULAR',
                            bg: const Color(0xFF10B981).withValues(alpha: 0.12),
                            fg: const Color(0xFF10B981),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colorScheme.onSurfaceVariant),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 18),
          Divider(height: 1, color: colorScheme.outlineVariant),
          const SizedBox(height: 14),
          Row(
            children: [
              _MetaItem(
                icon: Icons.layers_outlined,
                label: '$sectionsCount Sections',
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const SizedBox(width: 16),
              _MetaItem(
                icon: Icons.check_circle_outline_rounded,
                label: '$checkpointsCount Points',
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
              const Spacer(),
              _MetaItem(
                icon: Icons.schedule_rounded,
                label: '~${estimatedMinutes}m',
                colorScheme: colorScheme,
                textTheme: textTheme,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _MetaItem({
    required this.icon,
    required this.label,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
