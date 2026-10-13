import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'package:staff_app/l10n/gen/staff_localizations.dart';
import 'advisor_sheet.dart';
import 'advisor_divider.dart';
import 'advisor_menu_item.dart';
import 'advisor_outline_action.dart';

/// Advisor account menu sheet: identity header plus profile / attendance /
/// logout rows. The logout confirmation flow is owned by the caller.
class AdvisorProfileSheet extends ConsumerWidget {
  final VoidCallback onLogout;
  const AdvisorProfileSheet({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(advisorInfoProvider);
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final t = StaffLocalizations.of(context)!;

    return AdvisorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 34,
                backgroundColor: colors.primary,
                child: Text(
                  info.initials,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: colors.onPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(height: AppDimensions.s14),
              Text(
                info.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: AppDimensions.s4),
              Text(
                '${info.id} · ${info.branch}',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppDimensions.s10),
              Center(
                child: StatusPill.success(
                  info.shift.isNotEmpty ? info.shift : t.advisorOnShift,
                  showDot: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppDimensions.s20),
          const AdvisorDivider(),
          AdvisorMenuItem(
            icon: Icons.person_outline_rounded,
            label: t.advisorProfileMyProfile,
            onTap: () {
              Navigator.pop(context);
              context.push(
                AppRoutes.profile,
                extra: ProfileData(
                  name: info.name,
                  id: info.id,
                  role: t.advisorWorkspaceName,
                  branch: info.branch,
                  shift: info.shift,
                ),
              );
            },
          ),
          const AdvisorDivider(),
          AdvisorMenuItem(
            icon: Icons.fingerprint_rounded,
            label: t.advisorProfileAttendance,
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.attendance);
            },
          ),
          const AdvisorDivider(),
          const SizedBox(height: AppDimensions.s8),
          AdvisorOutlineAction(
            label: t.advisorProfileLogout,
            icon: Icons.logout_rounded,
            color: colors.error,
            onTap: onLogout,
          ),
        ],
      ),
    );
  }
}
