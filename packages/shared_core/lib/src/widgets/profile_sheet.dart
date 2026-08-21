import 'package:flutter/material.dart';
import 'package:shared_core/src/theme/app_dimensions.dart';
import 'package:shared_core/src/widgets/app_record_row.dart';
import 'package:shared_core/src/widgets/logout_dialog.dart';
import 'package:shared_core/src/widgets/status_pill.dart';

class ProfileSheetItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ProfileSheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class ProfileSheetData {
  final String name;
  final String initials;
  final String roleLabel;
  final String roleBadge;
  final String branch;
  final List<ProfileSheetItem> menuItems;

  const ProfileSheetData({
    required this.name,
    required this.initials,
    required this.roleLabel,
    required this.roleBadge,
    this.branch = '',
    this.menuItems = const [],
  });
}

void showProfileSheet(
  BuildContext context,
  ProfileSheetData data, {
  VoidCallback? onLogout,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) =>
        _ProfileSheetContent(data: data, onLogout: onLogout),
  );
}

class _ProfileSheetContent extends StatelessWidget {
  final ProfileSheetData data;
  final VoidCallback? onLogout;

  const _ProfileSheetContent({required this.data, this.onLogout});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppDimensions.s20,
          AppDimensions.s8,
          AppDimensions.s20,
          AppDimensions.s24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colors.primaryContainer,
                  foregroundColor: colors.onPrimaryContainer,
                  child: Text(
                    data.initials,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: colors.onPrimaryContainer,
                    ),
                  ),
                ),
                const SizedBox(width: AppDimensions.s14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data.name, style: theme.textTheme.titleLarge),
                      const SizedBox(height: AppDimensions.s4),
                      Text(
                        data.roleLabel,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                StatusPill(label: data.roleBadge),
              ],
            ),
            if (data.branch.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s14),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: colors.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppDimensions.s6),
                  Expanded(
                    child: Text(
                      data.branch,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colors.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (data.menuItems.isNotEmpty) ...[
              const SizedBox(height: AppDimensions.s24),
              ...data.menuItems.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: AppDimensions.s8),
                  child: AppRecordRow(
                    leading: Icon(item.icon, color: colors.onSurfaceVariant),
                    title: item.label,
                    trailing: Icon(
                      Icons.chevron_right_rounded,
                      color: colors.onSurfaceVariant,
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      item.onTap();
                    },
                  ),
                ),
              ),
            ],
            const SizedBox(height: AppDimensions.s16),
            OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showLogoutDialog(context, onLogout: onLogout);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: colors.error,
                side: BorderSide(color: colors.error),
              ),
              icon: const Icon(Icons.logout_rounded),
              label: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
