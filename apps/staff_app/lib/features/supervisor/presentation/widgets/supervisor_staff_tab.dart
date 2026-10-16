import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';

import 'package:staff_app/features/supervisor/presentation/providers/supervisor_providers.dart';
import 'package:staff_app/features/supervisor/presentation/widgets/supervisor_components.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';

/// Workshop roster: floor technicians and departments as borderless rows.
/// Only real registered roster entries render — no invented availability or
/// capacity claims.
class SupervisorStaffTab extends ConsumerWidget {
  const SupervisorStaffTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = StaffLocalizations.of(context)!;
    final notifier = ref.read(supervisorDashboardProvider.notifier);
    final technicians = notifier.technicians;
    final departments = notifier.departments;

    return AppResponsivePage(
      padding: EdgeInsets.fromLTRB(
        context.pagePadding.left,
        AppDimensions.s16,
        context.pagePadding.right,
        AppDimensions.s40,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppPageHeader(
            title: t.svStaffTitle,
            subtitle: t.svStaffSubtitle(technicians.length),
            leading: const Icon(Icons.groups_outlined),
          ),
          const SizedBox(height: AppDimensions.s20),
          SectionHeader(
            title: t.svStaffTechnicians,
            leadingIcon: Icons.engineering_outlined,
            count: technicians.length,
          ),
          if (technicians.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.s20),
              child: EmptyState(
                icon: Icons.badge_outlined,
                title: t.svStaffEmpty,
                message: t.svStaffEmptyMessage,
              ),
            )
          else
            for (final name in technicians) _TechnicianRow(name: name),
          const SizedBox(height: AppDimensions.s24),
          SectionHeader(
            title: t.svStaffDepartments,
            leadingIcon: Icons.domain_outlined,
            count: departments.length,
          ),
          if (departments.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppDimensions.s20),
              child: EmptyState(
                icon: Icons.precision_manufacturing_outlined,
                title: t.svStaffDeptEmpty,
                message: t.svStaffDeptEmptyMessage,
              ),
            )
          else
            for (final dept in departments) _DepartmentRow(name: dept),
        ],
      ),
    );
  }
}

class _TechnicianRow extends StatelessWidget {
  final String name;
  const _TechnicianRow({required this.name});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    final initials = initialsOf(name);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: context.colors.primary.withValues(alpha: 0.12),
                child: Text(
                  initials,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: context.colors.onSurface,
                      ),
                    ),
                    Text(
                      t.svStaffRole,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: context.colors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppDimensions.s8),
              StatusPill.success(t.svStaffOnShift),
            ],
          ),
        ),
        Divider(height: 1, color: context.colors.outlineVariant),
      ],
    );
  }
}

class _DepartmentRow extends StatelessWidget {
  final String name;
  const _DepartmentRow({required this.name});

  @override
  Widget build(BuildContext context) {
    final t = StaffLocalizations.of(context)!;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: AppDimensions.s10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: context.semanticColors.surfaceSubtle,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusControl),
                ),
                child: Icon(
                  Icons.precision_manufacturing_outlined,
                  size: AppDimensions.iconMd,
                  color: context.colors.primary,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: context.colors.onSurface,
                  ),
                ),
              ),
              Text(
                t.svWorkspaceName,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: context.colors.outlineVariant),
      ],
    );
  }
}
