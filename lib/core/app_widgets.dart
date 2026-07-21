// lib/core/widgets/app_widgets.dart
//
// Shared UI widgets used across multiple customer views.
// Import this file (or re-export via a barrel) wherever needed.
//
import 'package:flutter/material.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';

// ─────────────────────────────────────────────────────────────────
// InnerTopBar
// A standard top-bar for inner (non-dashboard) screens.
// ─────────────────────────────────────────────────────────────────
class InnerTopBar extends StatelessWidget {
  final String title;
  final Widget? trailing;

  const InnerTopBar({
    super.key,
    required this.title,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bg,
                border: Border.all(color: AppColors.border),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 14,
                color: AppColors.text3,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// CustomerTopBar
// Dashboard-specific top bar with avatar, name and notification bell.
// ─────────────────────────────────────────────────────────────────
class CustomerTopBar extends StatelessWidget {
  final String avatarInitials;
  final String name;
  final int notifCount;
  final VoidCallback onNotif;

  const CustomerTopBar({
    super.key,
    required this.avatarInitials,
    required this.name,
    required this.notifCount,
    required this.onNotif,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          // Avatar circle
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primaryBorder),
            ),
            child: Center(
              child: Text(
                avatarInitials,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Welcome back,',
                  style: TextStyle(fontSize: 11, color: AppColors.text3),
                ),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          // Notification bell
          GestureDetector(
            onTap: onNotif,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.border),
                  ),
                  child: const Icon(
                    Icons.notifications_outlined,
                    size: 20,
                    color: AppColors.text2,
                  ),
                ),
                if (notifCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: const BoxDecoration(
                        color: AppColors.danger,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$notifCount',
                          style: const TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
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

// ─────────────────────────────────────────────────────────────────
// StatusPill
// Small coloured pill badge used for status labels.
// ─────────────────────────────────────────────────────────────────
class StatusPill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;

  const StatusPill({
    super.key,
    required this.label,
    required this.bg,
    required this.fg,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// SectionHeader
// Row with a bold title and optional right-side action link.
// ─────────────────────────────────────────────────────────────────
class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({
    super.key,
    required this.title,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}