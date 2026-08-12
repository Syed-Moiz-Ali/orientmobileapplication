import 'package:customer_app/core/router/app_router.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

class CustomerProfileTab extends ConsumerWidget {
  const CustomerProfileTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textTheme = Theme.of(context).textTheme;
    final state = ref.watch(customerDashboardProvider);
    final profile = state.profile;

    final name = profile?.name.isNotEmpty == true
        ? profile!.name
        : (profile?.firstName.isNotEmpty == true
              ? profile!.firstName
              : 'Customer Profile');
    final initials = profile?.avatarInitials.isNotEmpty == true
        ? profile!.avatarInitials
        : 'C';
    final memberId = profile?.memberId.isNotEmpty == true
        ? profile!.memberId
        : '102';

    return SafeArea(
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. PAGE HEADER (Matches Home Tab Header Pattern)
            Padding(
              padding: const EdgeInsets.only(
                top: AppDimensions.s12,
                bottom: AppDimensions.s8,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Account & Settings 👤',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.headlineLarge?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w900,
                            fontSize: 26,
                            letterSpacing: -0.8,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your VIP membership, app security & preferences',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.text3,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s12),
                  GestureDetector(
                    onTap: () => context.push(AppRoutes.customerNotifications),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.notifications_outlined,
                            color: AppColors.textPrimary,
                            size: 22,
                          ),
                        ),
                        if (state.unreadCount > 0)
                          Positioned(
                            top: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.danger,
                                borderRadius: BorderRadius.circular(
                                  AppDimensions.rPill,
                                ),
                                border: Border.all(
                                  color: AppColors.bg,
                                  width: 2,
                                ),
                              ),
                              child: Text(
                                state.unreadCount > 99
                                    ? '99+'
                                    : '${state.unreadCount}',
                                style: textTheme.labelSmall?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.s16),

            // 2. HERO PROFILE INFO CARD (High Contrast Primary Card)
            AppCard(
              color: AppColors.primary,
              borderRadius: 24,
              padding: const EdgeInsets.all(AppDimensions.s16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.28),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 2,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        initials,
                        style: textTheme.headlineSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppDimensions.s14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 20,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Member #$memberId • Workshop Verified',
                          style: textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.9),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(
                              AppDimensions.rPill,
                            ),
                          ),
                          child: Text(
                            'VIP MEMBERSHIP ACTIVE',
                            style: textTheme.labelSmall?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 9,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppDimensions.s16),

            // 3. STATS ROW (r24 Cards)
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Registered Cars',
                    value: '${state.vehicles.length}',
                    icon: Icons.directions_car_filled_rounded,
                  ),
                ),
                const SizedBox(width: AppDimensions.s10),
                Expanded(
                  child: _StatTile(
                    label: 'Loyalty Points',
                    value: '1,450 PTS',
                    icon: Icons.stars_rounded,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s16),

            // 4. LOYALTY REWARDS & SAVINGS BANNER CARD
            _LoyaltyRewardsCard(
              onRedeem: () => context.push(AppRoutes.customerBookService),
            ),
            const SizedBox(height: AppDimensions.s24),

            // 5. ACCOUNT SETTINGS (r24 Group Cards)
            _ExplanatorySectionHeader(
              title: 'Garage & Breakdown Shortcuts',
              subtitle:
                  'Manage registered cars, breakdown assistance & appointments',
            ),
            const SizedBox(height: AppDimensions.s10),
            _SettingsGroup(
              items: [
                _SettingsTile(
                  icon: Icons.directions_car_rounded,
                  title: 'My Garage & Vehicles',
                  subtitle: 'Manage registered cars, MOT & service details',
                  onTap: () =>
                      ref.read(customerDashboardProvider.notifier).selectTab(3),
                ),
                _SettingsTile(
                  icon: Icons.add_rounded,
                  title: 'Register New Vehicle',
                  subtitle: 'Add a new vehicle to your garage',
                  onTap: () => context.push(AppRoutes.customerAddVehicle),
                ),
                _SettingsTile(
                  icon: Icons.emergency_rounded,
                  title: 'Breakdown & SOS Assistance',
                  subtitle: 'Get 24/7 roadside emergency support',
                  onTap: () => context.push(AppRoutes.customerBreakdownHelp),
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s24),

            // 6. PREFERENCES & SECURITY (r24 Group Cards)
            _ExplanatorySectionHeader(
              title: 'App Preferences & Security',
              subtitle: 'Configure notifications, Face ID security & support',
            ),
            const SizedBox(height: AppDimensions.s10),
            _SettingsGroup(
              items: [
                _SettingsTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Push Notifications',
                  subtitle: 'Receive workshop stage updates & invoice alerts',
                  trailing: Switch.adaptive(
                    value: true,
                    activeTrackColor: AppColors.primary,
                    onChanged: (_) {},
                  ),
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.lock_outline_rounded,
                  title: 'Security & Biometrics',
                  subtitle: 'Protect app access with Face ID / Fingerprint',
                  onTap: () {},
                ),
                _SettingsTile(
                  icon: Icons.help_outline_rounded,
                  title: 'Help & Workshop Support',
                  subtitle: 'Contact workshop advisor, FAQs & support',
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: AppDimensions.s28),

            // 7. LOGOUT BUTTON
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dangerBg,
                  foregroundColor: AppColors.danger,
                  elevation: 0,
                  side: const BorderSide(color: AppColors.dangerBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.rPill),
                  ),
                ),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: Text(
                  'Log Out of Account',
                  style: textTheme.labelLarge?.copyWith(
                    color: AppColors.danger,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppDimensions.s32),
          ],
        ),
      ),
    );
  }
}

/// LOYALTY REWARDS & SAVINGS CARD
class _LoyaltyRewardsCard extends StatelessWidget {
  final VoidCallback onRedeem;

  const _LoyaltyRewardsCard({required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(AppDimensions.s16),
      color: AppColors.surface,
      borderColor: AppColors.border,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.card_giftcard_rounded,
                  color: AppColors.accent,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppDimensions.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '£14.50 Service Credit Available',
                      style: textTheme.titleSmall?.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    Text(
                      'From 1,450 Orient Loyalty Points',
                      style: textTheme.bodySmall?.copyWith(
                        color: AppColors.text3,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: onRedeem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppDimensions.rPill),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.s12,
                    vertical: AppDimensions.s8,
                  ),
                ),
                child: const Text(
                  'Claim Credit',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 11),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(AppDimensions.s12),
      color: AppColors.surface,
      borderColor: AppColors.border,
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 18),
          ),
          const SizedBox(width: AppDimensions.s10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: textTheme.titleSmall?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  label,
                  style: textTheme.bodySmall?.copyWith(
                    color: AppColors.text3,
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

class _ExplanatorySectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ExplanatorySectionHeader({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: textTheme.bodySmall?.copyWith(
            color: AppColors.text3,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SettingsGroup extends StatelessWidget {
  final List<Widget> items;

  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: AppColors.surface,
      borderColor: AppColors.border,
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1)
              const Divider(height: 1, color: AppColors.line),
          ],
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.s14,
          vertical: AppDimensions.s12,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primaryBg,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 18),
            ),
            const SizedBox(width: AppDimensions.s12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: AppColors.text3,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.text4,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
