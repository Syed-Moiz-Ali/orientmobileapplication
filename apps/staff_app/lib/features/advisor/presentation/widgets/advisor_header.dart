import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'advisor_avatar.dart';
import 'advisor_meta_pill.dart';
import 'advisor_header_button.dart';

class AdvisorHeader extends StatelessWidget {
  final String advisorName;
  final String advisorInitials;
  final String advisorBranch;
  final VoidCallback onShowProfile;
  final VoidCallback onShowNotifications;
  final VoidCallback onShowSearch;
  final VoidCallback onOpenScan;
  final VoidCallback onNewJobCard;
  final VoidCallback onOpenInspection;

  const AdvisorHeader({
    super.key,
    required this.advisorName,
    required this.advisorInitials,
    required this.advisorBranch,
    required this.onShowProfile,
    required this.onShowNotifications,
    required this.onShowSearch,
    required this.onOpenScan,
    required this.onNewJobCard,
    required this.onOpenInspection,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.surface,
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: onShowProfile,
                    child: Row(
                      children: [
                        AdvisorAvatar(initials: advisorInitials, size: 40),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              advisorName,
                              style: TextStyle(
                                color: colors.onSurface,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: colors.primary,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'On Shift',
                                  style: TextStyle(
                                    color: colors.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.notifications_outlined,
                          color: colors.onSurface,
                          size: 26,
                        ),
                        onPressed: onShowNotifications,
                      ),
                      Positioned(
                        right: 10,
                        top: 10,
                        child: Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.amber400,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: colors.surface,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 4),
                    child: GestureDetector(
                      onTap: onShowProfile,
                      child: Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.30),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            advisorInitials.substring(0, 1),
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Row(
                children: [
                  AdvisorMetaPill(
                    icon: Icons.business_outlined,
                    label: advisorBranch,
                  ),
                  SizedBox(width: 8),
                  AdvisorMetaPill(
                    icon: Icons.schedule_outlined,
                    label: '08:00 – 17:00',
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
              child: Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    margin: const EdgeInsets.only(right: 6, top: 1),
                    decoration: BoxDecoration(
                      color: colors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Text(
                    'Live',
                    style: TextStyle(
                      color: colors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Good Morning,',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Advisor Dashboard',
                    style: TextStyle(
                      color: colors.onSurface,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Semantics(
                      button: true,
                      label: 'Search',
                      child: GestureDetector(
                        onTap: onShowSearch,
                        child: Container(
                          height: 42,
                          decoration: BoxDecoration(
                            color: colors.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.r11,
                            ),
                            border: Border.all(color: colors.outlineVariant),
                          ),
                          child: Row(
                            children: [
                              const SizedBox(width: 12),
                              Icon(
                                Icons.search_rounded,
                                color: colors.onSurfaceVariant,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Search name, plate, phone…',
                                style: TextStyle(
                                  color: colors.onSurfaceVariant,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Semantics(
                    button: true,
                    label: 'Scan vehicle QR code',
                    child: GestureDetector(
                      onTap: onOpenScan,
                      child: Container(
                        height: 42,
                        width: 42,
                        decoration: BoxDecoration(
                          color: colors.primary.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(
                            AppDimensions.r11,
                          ),
                          border: Border.all(
                            color: colors.primary.withValues(alpha: 0.30),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.15),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.qr_code_scanner_rounded,
                          color: colors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
              child: Row(
                children: [
                  Expanded(
                    child: AdvisorHeaderButton(
                      label: '+ New Job Card',
                      isPrimary: true,
                      onTap: onNewJobCard,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: AdvisorHeaderButton(
                      label: 'Inspection',
                      icon: Icons.checklist_rounded,
                      isPrimary: false,
                      onTap: onOpenInspection,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              height: 24,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
