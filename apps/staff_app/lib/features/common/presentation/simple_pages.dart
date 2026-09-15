import 'package:flutter/material.dart';
import 'package:shared_core/shared_core.dart';

class ShiftDetailsPage extends StatelessWidget {
  final Map<String, dynamic>? data;

  const ShiftDetailsPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final map = data ?? const {};
    String get(String key) => (map[key] as String? ?? '--');

    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Shift Details',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: AppResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoTile(label: 'Employee', value: get('name')),
              _InfoTile(label: 'ID', value: get('id')),
              _InfoTile(label: 'Shift', value: get('shift')),
              _InfoTile(label: 'Start', value: get('start')),
              _InfoTile(label: 'End', value: get('end')),
              _InfoTile(label: 'Branch', value: get('branch')),
            ],
          ),
        ),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  final Map<String, dynamic>? data;

  const SettingsPage({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    final version = (data?['version'] as String?) ?? '1.0.0';
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: colors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: colors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colors.onSurface),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Settings',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: colors.onSurface,
          ),
        ),
      ),
      body: SafeArea(
        child: AppResponsivePage(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _InfoTile(
                icon: Icons.info_outline_rounded,
                label: 'App Version',
                value: version,
              ),
              _InfoTile(
                icon: Icons.sync_rounded,
                label: 'Sync Status',
                value: HiveCleaner.hasPendingSync()
                    ? 'Pending operations'
                    : 'Up to date',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData? icon;
  final String label;
  final String value;

  const _InfoTile({this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outlineVariant.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 20, color: colors.onSurfaceVariant),
            const SizedBox(width: 14),
          ],
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: colors.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
