import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';
import 'package:orientmobileapplication/core/theme/app_text_styles.dart';
import 'package:orientmobileapplication/core/widgets/logout_dialog.dart';

class ProfileSheetItem {
  final IconData icon;
  final String label;
  final String route;
  final Map<String, dynamic>? extra;

  const ProfileSheetItem({
    required this.icon,
    required this.label,
    required this.route,
    this.extra,
  });
}

class ProfileSheetData {
  final String name;
  final String initials;
  final String roleLabel;
  final String roleBadge;
  final List<ProfileSheetItem> menuItems;

  const ProfileSheetData({
    required this.name,
    required this.initials,
    required this.roleLabel,
    required this.roleBadge,
    this.menuItems = const [],
  });
}

void showProfileSheet(BuildContext context, ProfileSheetData data) {
  showModalBottomSheet(
    context: context,
    backgroundColor: AppColors.surface,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(AppDimensions.r2),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: 68, height: 68,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.navy, AppColors.accent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                data.initials,
                style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Text(data.roleLabel, style: AppTextStyles.rajdhaniTitle(color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(AppDimensions.r20),
            ),
            child: Text(data.roleBadge, style: AppTextStyles.rajdhaniBodySmall(color: AppColors.primary)),
          ),
          const SizedBox(height: 24),
          for (final item in data.menuItems) ...[
            _menuItem(context, icon: item.icon, label: item.label, onTap: () {
              Navigator.pop(context);
              if (item.extra != null) {
                context.push(item.route, extra: item.extra);
              } else {
                context.push(item.route);
              }
            }),
          ],
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity, height: 50,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                showLogoutDialog(context);
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: const BorderSide(color: AppColors.danger, width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppDimensions.r14)),
              ),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Logout', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _menuItem(BuildContext context, {
  required IconData icon,
  required String label,
  required VoidCallback onTap,
}) {
  return Padding(
    padding: EdgeInsets.only(bottom: AppDimensions.s6),
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.r12),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppDimensions.s12, vertical: AppDimensions.s14),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppColors.text2),
              SizedBox(width: AppDimensions.s12),
              Text(label, style: AppTextStyles.rajdhaniBody(color: AppColors.textPrimary)),
              const Spacer(),
              Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.text3),
            ],
          ),
        ),
      ),
    ),
  );
}
