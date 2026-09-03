import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

class StaffProfileScreen extends ConsumerWidget {
  const StaffProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final auth = ref.watch(authNotifierProvider);
    final profile = auth is AuthAuthenticated ? auth.profile : null;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: _PressScale(
          onTap: () {
            HapticFeedback.selectionClick();
            context.pop();
          },
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Icon(
              Icons.arrow_back_rounded,
              color: colorScheme.onSurface,
              size: 20,
            ),
          ),
        ),
        centerTitle: true,
        title: Text(
          'Staff Profile',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.3,
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 60),
        child: Column(
          children: [
            // ── 1. AVATAR & HERO PROFILE ─────────────────────────────────────
            _ProfileHeroCard(profile: profile),
            const SizedBox(height: 20),

            // ── 2. SHIFT & OPERATIONAL METRICS ───────────────────────────────
            _ShiftMetricsGrid(profile: profile),
            const SizedBox(height: 24),

            // ── 3. WORKSPACE & PREFERENCES BENTO ─────────────────────────────
            _SectionHeader(title: 'Workshop Preferences'),
            const SizedBox(height: 12),
            _PreferencesBentoGroup(),
            const SizedBox(height: 24),

            // ── 4. SECURITY & SYSTEM ACTIONS ─────────────────────────────────
            _SectionHeader(title: 'Security & Access'),
            const SizedBox(height: 12),
            _SecurityBentoGroup(),
            const SizedBox(height: 32),

            // ── 5. LOGOUT BUTTON ─────────────────────────────────────────────
            _LogoutButton(),
          ],
        ),
      ),
    );
  }
}

// ─── 1. PROFILE HERO CARD ────────────────────────────────────────────────────
class _ProfileHeroCard extends StatelessWidget {
  final MeResponse? profile;
  const _ProfileHeroCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: colorScheme.primary, width: 2),
                ),
                child: CircleAvatar(
                  radius: 42,
                  backgroundColor: colorScheme.primaryContainer,
                  child: Text(
                    profile?.initials ?? 'S',
                    style: textTheme.headlineMedium?.copyWith(
                      color: colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            profile?.name.isNotEmpty == true ? profile!.name : 'Supervisor',
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: colorScheme.onSurface,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            profile?.designation.isNotEmpty == true
                ? profile!.designation
                : 'Supervisor',
            style: textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  profile?.empId.isNotEmpty == true
                      ? 'STAFF ID: ${profile!.empId}'
                      : 'STAFF ACCOUNT',
                  style: textTheme.labelSmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w900,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.circle, color: Color(0xFF10B981), size: 6),
                    const SizedBox(width: 6),
                    Text(
                      profile?.branchName.isNotEmpty == true
                          ? profile!.branchName.toUpperCase()
                          : 'ACTIVE',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── 2. SHIFT METRICS GRID ───────────────────────────────────────────────────
class _ShiftMetricsGrid extends StatelessWidget {
  final MeResponse? profile;
  const _ShiftMetricsGrid({required this.profile});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        _MetricTile(
          value: profile?.shift.isNotEmpty == true ? profile!.shift : 'Not set',
          label: 'Shift',
          color: colorScheme.primary,
          icon: Icons.schedule_rounded,
        ),
        const SizedBox(width: 8),
        _MetricTile(
          value: profile?.branchName.isNotEmpty == true
              ? profile!.branchName
              : 'Not set',
          label: 'Branch',
          color: const Color(0xFF10B981),
          icon: Icons.verified_outlined,
        ),
        const SizedBox(width: 8),
        _MetricTile(
          value: profile?.department.isNotEmpty == true
              ? profile!.department
              : 'Not set',
          label: 'Department',
          color: colorScheme.secondary,
          icon: Icons.badge_outlined,
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _MetricTile({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w900,
                color: colorScheme.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── 3. PREFERENCES BENTO GROUP ──────────────────────────────────────────────
class _PreferencesBentoGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.notifications_active_outlined,
            title: 'Push Alerts & Dispatch Bleeps',
            subtitle: 'Real-time emergency & booking cues',
            trailing: Switch.adaptive(
              value: true,
              activeTrackColor: colorScheme.primary,
              onChanged: (_) => HapticFeedback.selectionClick(),
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant, indent: 56),
          _SettingsRow(
            icon: Icons.speed_rounded,
            title: 'Diagnostic HUD Telemetry',
            subtitle: 'Display raw sensor feeds on active jobs',
            trailing: Switch.adaptive(
              value: true,
              activeTrackColor: colorScheme.primary,
              onChanged: (_) => HapticFeedback.selectionClick(),
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant, indent: 56),
          _SettingsRow(
            icon: Icons.dark_mode_outlined,
            title: 'Workshop High-Contrast Mode',
            subtitle: 'Optimized for low-light shop floor',
            trailing: Switch.adaptive(
              value: true,
              activeTrackColor: colorScheme.primary,
              onChanged: (_) => HapticFeedback.selectionClick(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── 4. SECURITY BENTO GROUP ─────────────────────────────────────────────────
class _SecurityBentoGroup extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          _SettingsRow(
            icon: Icons.fingerprint_rounded,
            title: 'Biometric Station Login',
            subtitle: 'Touch ID / Face unlock enabled',
            onTap: () => HapticFeedback.selectionClick(),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          Divider(height: 1, color: colorScheme.outlineVariant, indent: 56),
          _SettingsRow(
            icon: Icons.pin_outlined,
            title: 'Account credentials',
            subtitle: 'Managed securely from the sign-in flow',
            trailing: Icon(
              Icons.lock_outline_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 20, color: colorScheme.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}

// ─── 5. LOGOUT BUTTON ────────────────────────────────────────────────────────
class _LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return _PressScale(
      onTap: () async {
        HapticFeedback.heavyImpact();
        await showLogoutDialog(
          context,
          onLogout: () {
            ref.read(authNotifierProvider.notifier).logout();
          },
        );
      },
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: colorScheme.error.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.error.withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout_rounded, color: colorScheme.error, size: 18),
            const SizedBox(width: 8),
            Text(
              'Sign out',
              style: TextStyle(
                color: colorScheme.error,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── HEADINGS & HELPERS ──────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
            letterSpacing: -0.4,
          ),
        ),
      ],
    );
  }
}

class _PressScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;

  const _PressScale({required this.child, this.onTap});

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 140),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.97).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
      onTap: widget.onTap,
      child: ScaleTransition(scale: _scaleAnimation, child: widget.child),
    );
  }
}
