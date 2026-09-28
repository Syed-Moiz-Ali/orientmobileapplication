import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';
import 'package:staff_app/core/router/app_router.dart';
import 'package:staff_app/features/advisor/presentation/providers/advisor_providers.dart';
import 'advisor_sheet.dart';
import 'advisor_handle.dart';
import 'advisor_divider.dart';
import 'advisor_menu_item.dart';

class AdvisorProfileSheet extends ConsumerWidget {
  final VoidCallback onLogout;
  const AdvisorProfileSheet({super.key, required this.onLogout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final info = ref.watch(advisorInfoProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return AdvisorSheet(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const AdvisorHandle(),
          const SizedBox(height: 20),
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                info.initials,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 26,
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(
            info.name,
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 19,
              fontWeight: FontWeight.w700,
              letterSpacing: 0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${info.id} · Service Advisor',
            style: TextStyle(fontSize: 13, color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppDimensions.r20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                    color: Color(0xFF10B981),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  info.shift.isNotEmpty ? info.shift : 'On Shift',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AdvisorDivider(),
          AdvisorMenuItem(
            icon: Icons.person_outline_rounded,
            label: 'My Profile',
            onTap: () {
              Navigator.pop(context);
              context.push(
                AppRoutes.profile,
                extra: ProfileData(
                  name: info.name,
                  id: info.id,
                  role: 'Service Advisor',
                  branch: info.branch,
                  shift: info.shift,
                ),
              );
            },
          ),
          const AdvisorDivider(),
          AdvisorMenuItem(
            icon: Icons.fingerprint_rounded,
            label: 'Attendance · Punch In / Out',
            onTap: () {
              Navigator.pop(context);
              context.push(AppRoutes.attendance);
            },
          ),
          const AdvisorDivider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton.icon(
                onPressed: onLogout,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error, width: 1.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.r14),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  'Logout',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: colorScheme.error,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
