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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    final state = ref.watch(customerDashboardProvider);
    final profile = state.profile;

    final name = profile?.name.isNotEmpty == true
        ? profile!.name
        : (profile?.firstName.isNotEmpty == true ? profile!.firstName : 'Customer Profile');
    final initials = profile?.avatarInitials.isNotEmpty == true ? profile!.avatarInitials : 'C';
    final memberId = profile?.memberId.isNotEmpty == true ? profile!.memberId : '102';

    return SafeArea(
      child: AppResponsivePage(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),

            // ── 1. PREMIUM HEADER ──────────────────────────────────────────
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: textTheme.headlineMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your VIP membership & preferences',
                        style: textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () => context.push(AppRoutes.customerNotifications),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: colorScheme.outlineVariant),
                        ),
                        child: Icon(Icons.notifications_outlined, color: colorScheme.onSurface, size: 24),
                      ),
                      if (state.unreadCount > 0)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.error,
                              borderRadius: BorderRadius.circular(100),
                              border: Border.all(color: colorScheme.surface, width: 2),
                            ),
                            child: Text(
                              state.unreadCount > 99 ? '99+' : '${state.unreadCount}',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.onError,
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
            const SizedBox(height: 32),

            // ── 2. HERO PROFILE INFO CARD (Premium Gradient) ─────────────────
            AppCard(
              borderRadius: 24,
              elevation: 0,
              padding: EdgeInsets.zero,
              boxShadow: [
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.2),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ],
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colorScheme.primary, colorScheme.primaryContainer],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.onPrimary.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: colorScheme.onPrimary.withValues(alpha: 0.3), width: 2),
                      ),
                      child: Center(
                        child: Text(
                          initials,
                          style: textTheme.headlineMedium?.copyWith(
                            color: colorScheme.onPrimary,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.titleLarge?.copyWith(
                              color: colorScheme.onPrimary,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Member #$memberId • Verified',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onPrimary.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: colorScheme.onPrimary,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Text(
                              'VIP ACTIVE',
                              style: textTheme.labelSmall?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.w900,
                                fontSize: 9,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── 3. STATS ROW ─────────────────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _StatTile(
                    label: 'Garage',
                    value: '${state.vehicles.length} Cars',
                    icon: Icons.directions_car_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatTile(label: 'Loyalty', value: '1,450 PTS', icon: Icons.stars_rounded),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // ── 4. NEW: REFER & EARN PROMO ───────────────────────────────────
            const _ReferAndEarnBanner(),
            const SizedBox(height: 36),

            // ── 5. LOYALTY REWARDS & SAVINGS CARD ────────────────────────────
            _ExplanatorySectionHeader(title: 'Your Rewards', subtitle: 'Claim your accumulated VIP credit'),
            const SizedBox(height: 16),
            _LoyaltyRewardsCard(onRedeem: () => context.push(AppRoutes.customerBookService)),
            const SizedBox(height: 36),

            // ── 6. ACCOUNT SETTINGS ──────────────────────────────────────────
            _ExplanatorySectionHeader(title: 'Garage Shortcuts', subtitle: 'Manage vehicles and breakdown assistance'),
            const SizedBox(height: 16),
            _SettingsGroup(
              items: [
                _SettingsTile(
                  icon: Icons.directions_car_rounded,
                  title: 'My Garage & Vehicles',
                  subtitle: 'Manage registered cars, MOT & service details',
                  onTap: () => ref.read(customerDashboardProvider.notifier).selectTab(3),
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
            const SizedBox(height: 36),

            // ── 7. PREFERENCES & SECURITY ────────────────────────────────────
            _ExplanatorySectionHeader(title: 'App Preferences', subtitle: 'Configure notifications and security'),
            const SizedBox(height: 16),
            _SettingsGroup(
              items: [
                _SettingsTile(
                  icon: Icons.notifications_active_rounded,
                  title: 'Push Notifications',
                  subtitle: 'Receive workshop stage updates & alerts',
                  trailing: Switch.adaptive(value: true, activeTrackColor: colorScheme.primary, onChanged: (_) {}),
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
            const SizedBox(height: 36),

            // ── 8. LOGOUT BUTTON ─────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).logout();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: colorScheme.errorContainer,
                  foregroundColor: colorScheme.error,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: Text(
                  'Log Out of Account',
                  style: textTheme.titleMedium?.copyWith(color: colorScheme.error, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }
}

// ─── NEW: REFER & EARN BANNER ────────────────────────────────────────────────
class _ReferAndEarnBanner extends StatelessWidget {
  const _ReferAndEarnBanner();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      height: 120,
      borderRadius: 24,
      elevation: 0,
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      padding: EdgeInsets.zero,
      boxShadow: [
        BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.05), blurRadius: 16, offset: const Offset(0, 6)),
      ],
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(Icons.redeem_rounded, size: 140, color: colorScheme.tertiary.withValues(alpha: 0.05)),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Invite friends, get £50',
                        style: textTheme.titleLarge?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Share your referral link to earn service credit.',
                        style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: colorScheme.tertiary, shape: BoxShape.circle),
                  child: Icon(Icons.share_rounded, color: colorScheme.onTertiary, size: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── LOYALTY REWARDS & SAVINGS CARD ──────────────────────────────────────────
class _LoyaltyRewardsCard extends StatelessWidget {
  final VoidCallback onRedeem;

  const _LoyaltyRewardsCard({required this.onRedeem});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return AppCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(20),
      color: colorScheme.surfaceContainerHighest,
      borderColor: Colors.transparent,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: colorScheme.secondary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(Icons.card_giftcard_rounded, color: colorScheme.secondary, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '£14.50 Available',
                  style: textTheme.titleMedium?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w900),
                ),
                Text(
                  'Ready to redeem on next service',
                  style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onRedeem,
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            child: const Text('Claim', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

// ─── STAT TILE ───────────────────────────────────────────────────────────────
class _StatTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatTile({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      borderRadius: 24,
      padding: const EdgeInsets.all(16),
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: colorScheme.primaryContainer, borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: colorScheme.onPrimaryContainer, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w900),
                ),
                Text(label, style: textTheme.labelSmall?.copyWith(color: colorScheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── EXPLANATORY SECTION HEADER ──────────────────────────────────────────────
class _ExplanatorySectionHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  const _ExplanatorySectionHeader({required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: textTheme.titleLarge?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 4),
        Text(subtitle, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

// ─── SETTINGS GROUP & TILES ──────────────────────────────────────────────────
class _SettingsGroup extends StatelessWidget {
  final List<Widget> items;

  const _SettingsGroup({required this.items});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return AppCard(
      borderRadius: 24,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: colorScheme.surface,
      borderColor: colorScheme.outlineVariant,
      boxShadow: [
        BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
      ],
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            items[i],
            if (i < items.length - 1) Divider(height: 1, color: colorScheme.outlineVariant),
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
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: colorScheme.onSurface, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(color: colorScheme.onSurface, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            if (trailing != null)
              trailing!
            else
              Icon(Icons.chevron_right_rounded, color: colorScheme.outline, size: 20),
          ],
        ),
      ),
    );
  }
}
