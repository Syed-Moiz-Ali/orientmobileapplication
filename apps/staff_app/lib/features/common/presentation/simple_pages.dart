import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';
import 'package:staff_app/core/models/profile_data.dart';

/// Minimal profile page showing the currently signed-in staff member's data.
class ProfilePage extends StatelessWidget {
  final ProfileData data;
  const ProfilePage({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final profile = data;
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.navy, AppColors.accent],
              ),
              borderRadius: BorderRadius.circular(AppDimensions.r18),
            ),
            child: Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: const BoxDecoration(
                    color: Colors.white24,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      profile.avatarInitials,
                      style: AppTextStyles.title(color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.name.isEmpty ? 'Staff Member' : profile.name,
                        style: AppTextStyles.title(color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${profile.id} · ${profile.role}',
                        style: AppTextStyles.bodySmall(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _row(Icons.business_outlined, 'Branch', profile.branch),
          _row(Icons.schedule_outlined, 'Shift', profile.shift),
          if (profile.email.isNotEmpty)
            _row(Icons.email_outlined, 'Email', profile.email),
          if (profile.phone.isNotEmpty)
            _row(Icons.phone_outlined, 'Phone', profile.phone),
          if (profile.totalJobs > 0)
            _row(Icons.work_outline, 'Total Jobs', '${profile.totalJobs}'),
          if (profile.completedJobs > 0)
            _row(
              Icons.verified_outlined,
              'Completed Jobs',
              '${profile.completedJobs}',
            ),
          if (profile.pendingJobs > 0)
            _row(
              Icons.hourglass_empty,
              'Pending Jobs',
              '${profile.pendingJobs}',
            ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.text3),
          const SizedBox(width: 12),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '--' : value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal shift details page (fed from the profile sheet's extras map).
class ShiftDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? data;
  const ShiftDetailsPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final map = data ?? const {};
    String get(String key) => (map[key] as String? ?? '--');
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Shift Details',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _row('Employee', get('name')),
          _row('ID', get('id')),
          _row('Shift', get('shift')),
          _row('Start', get('start')),
          _row('End', get('end')),
          _row('Branch', get('branch')),
        ],
      ),
    );
  }

  Widget _row(String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Minimal settings placeholder.
class SettingsPage extends StatelessWidget {
  final Map<String, dynamic>? data;
  const SettingsPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final version = (data?['version'] as String?) ?? '1.0.0';
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _row(Icons.info_outline_rounded, 'App Version', version),
          _row(
            Icons.sync_rounded,
            'Sync',
            HiveCleaner.hasPendingSync() ? 'Pending operations' : 'Up to date',
          ),
        ],
      ),
    );
  }

  Widget _row(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r14),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.text3),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.text2,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
