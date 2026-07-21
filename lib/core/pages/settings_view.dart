import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orientmobileapplication/core/theme/app_colors.dart';
import 'package:orientmobileapplication/core/theme/app_dimensions.dart';

class SettingsView extends StatefulWidget {
  final String appVersion;
  final VoidCallback? onLogout;

  const SettingsView({super.key, this.appVersion = '1.0.0', this.onLogout});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notifications = true;
  bool _darkMode = false;
  bool _biometric = false;
  String _language = 'English';
  bool _autoSync = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.canvas,
      appBar: AppBar(
        backgroundColor: AppColors.navy,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Settings',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionLabel('Preferences'),
            const SizedBox(height: 12),
            _settingsCard([
              _settingToggle(
                'Push Notifications',
                'Receive alerts for job updates and approvals',
                Icons.notifications_outlined,
                _notifications,
                (v) => setState(() => _notifications = v),
              ),
              _settingToggle(
                'Dark Mode',
                'Use dark theme across the application',
                Icons.dark_mode_outlined,
                _darkMode,
                (v) => setState(() => _darkMode = v),
              ),
              _settingToggle(
                'Biometric Login',
                'Use fingerprint or face ID to log in',
                Icons.fingerprint,
                _biometric,
                (v) => setState(() => _biometric = v),
              ),
              _settingToggle(
                'Auto Sync',
                'Automatically sync data when online',
                Icons.sync_rounded,
                _autoSync,
                (v) => setState(() => _autoSync = v),
              ),
            ]),
            const SizedBox(height: 24),
            _sectionLabel('General'),
            const SizedBox(height: 12),
            _settingsCard([
              _settingSelect(
                'Language',
                _language,
                Icons.language_outlined,
                () => _selectLanguage(),
              ),
              _settingClick(
                'Clear Cache',
                'Free up storage space',
                Icons.cleaning_services_outlined,
                () => _clearCache(),
              ),
              _settingClick(
                'Export Data',
                'Backup your data to device',
                Icons.backup_outlined,
                () => _exportData(),
              ),
            ]),
            const SizedBox(height: 24),
            _sectionLabel('About'),
            const SizedBox(height: 12),
            _settingsCard([
              _settingInfo('Version', widget.appVersion, Icons.info_outline),
              _settingClick(
                'Terms of Service',
                '',
                Icons.description_outlined,
                () => _showToast('Terms of Service'),
              ),
              _settingClick(
                'Privacy Policy',
                '',
                Icons.shield_outlined,
                () => _showToast('Privacy Policy'),
              ),
              _settingClick(
                'Licenses',
                '',
                Icons.article_outlined,
                () => showLicensePage(context: context),
              ),
            ]),
            if (widget.onLogout != null) ...[
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: widget.onLogout,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppDimensions.r14),
                    ),
                  ),
                  icon: const Icon(Icons.logout_rounded, size: 18),
                  label: const Text(
                    'Logout',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: AppColors.danger,
                    ),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: AppColors.accent,
            borderRadius: BorderRadius.circular(AppDimensions.r2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _settingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.r16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: List.generate(children.length, (i) {
          return Column(
            children: [
              if (i > 0)
                const Divider(
                  height: 1,
                  color: AppColors.line,
                  indent: 16,
                  endIndent: 16,
                ),
              children[i],
            ],
          );
        }),
      ),
    );
  }

  Widget _settingToggle(
    String label,
    String subtitle,
    IconData icon,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: Icon(icon, size: 18, color: AppColors.accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          SizedBox(
            height: 30,
            child: Switch(
              value: value,
              onChanged: onChanged,
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accent.withValues(alpha: 0.3),
              inactiveThumbColor: AppColors.text3,
              inactiveTrackColor: AppColors.line,
            ),
          ),
        ],
      ),
    );
  }

  Widget _settingSelect(
    String label,
    String value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppDimensions.r10),
              ),
              child: Icon(icon, size: 18, color: AppColors.warning),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.text3,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.stroke,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingClick(
    String label,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppDimensions.r10),
              ),
              child: Icon(icon, size: 18, color: AppColors.info),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const Icon(
              Icons.chevron_right_rounded,
              color: AppColors.stroke,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingInfo(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.text3.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppDimensions.r10),
            ),
            child: Icon(icon, size: 18, color: AppColors.text3),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.text3,
            ),
          ),
        ],
      ),
    );
  }

  void _selectLanguage() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppDimensions.r28),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Select Language',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ...[
              ('English', 'English', Icons.language),
              ('Arabic', 'العربية', Icons.language),
              ('Urdu', 'اردو', Icons.language),
            ].map(
              (l) => ListTile(
                leading: Icon(
                  l.$3,
                  color: _language == l.$1 ? AppColors.accent : AppColors.text3,
                ),
                title: Text(
                  l.$1,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: _language == l.$1
                        ? AppColors.accent
                        : AppColors.textPrimary,
                  ),
                ),
                subtitle: Text(
                  l.$2,
                  style: const TextStyle(fontSize: 12, color: AppColors.text3),
                ),
                trailing: _language == l.$1
                    ? const Icon(
                        Icons.check_circle,
                        color: AppColors.accent,
                        size: 20,
                      )
                    : null,
                onTap: () {
                  setState(() => _language = l.$1);
                  Navigator.pop(ctx);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _clearCache() {
    _showToast('Cache cleared successfully');
  }

  void _exportData() {
    _showToast('Data exported to device storage');
  }

  void _showToast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              msg,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.r12),
        ),
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      ),
    );
  }
}
