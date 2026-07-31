import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import 'package:crm_app/features/crm_dashboard/presentation/crm_constants.dart';
import 'package:crm_app/features/crm_dashboard/presentation/providers/crm_ui_provider.dart';
import 'package:crm_app/features/crm_dashboard/presentation/widgets/connect_integration_sheet.dart';
import 'package:crm_app/features/crm_dashboard/domain/entities/crm_entities.dart';

class CrmIntegrationsPage extends ConsumerWidget {
  const CrmIntegrationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(crmUiProvider);
    final ui = ref.read(crmUiProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel('Integrations'),
          const SizedBox(height: 4),
          const Text(
            'Connect Meta, Zoho and other platforms to fetch leads automatically',
            style: TextStyle(color: CrmColors.textM, fontSize: 12),
          ),
          const SizedBox(height: AppDimensions.s16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.45,
            ),
            itemCount: ui.integrations.length,
            itemBuilder: (_, i) {
              final integration = ui.integrations[i];
              return _CrmIntegrationCard(
                integration: integration,
                onTap: () => _showIntegrationSheet(context, ref, integration),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _showIntegrationSheet(
      BuildContext context, WidgetRef ref, IntegrationEntity integration) async {
    if (!integration.connected) {
      await ConnectIntegrationSheet.show(context, platform: integration.name);
      return;
    }
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _ConnectedSheet(integration: integration),
    );
  }

  Widget _sectionLabel(String text) => Row(
    children: [
      Container(
        width: 4,
        height: 20,
        decoration: BoxDecoration(
          color: CrmColors.accent,
          borderRadius: BorderRadius.circular(AppDimensions.r2),
        ),
      ),
      const SizedBox(width: AppDimensions.s10),
      Text(
        text,
        style: const TextStyle(
          color: CrmColors.textH,
          fontSize: 19,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    ],
  );
}

class _CrmIntegrationCard extends StatelessWidget {
  final IntegrationEntity integration;
  final VoidCallback onTap;
  const _CrmIntegrationCard({required this.integration, required this.onTap});

  Color get _statusColor {
    if (integration.hasError) return CrmColors.red;
    if (integration.isSyncing) return CrmColors.amber;
    if (integration.connected) return CrmColors.green;
    return CrmColors.textM;
  }

  String get _statusLabel {
    if (integration.isSyncing) return 'Syncing...';
    if (integration.hasError) return 'Sync error';
    if (integration.connected) return 'Connected';
    return 'Not connected';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppDimensions.r14),
          border: Border.all(
            color: integration.connected
                ? integration.color.withValues(alpha: 0.25)
                : CrmColors.border,
          ),
          boxShadow: [
            BoxShadow(
              color: CrmColors.primary.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(integration.icon, color: integration.color, size: 24),
                const Spacer(),
                if (integration.connected)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: CrmColors.greenBg,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '${integration.leadCount}',
                      style: const TextStyle(
                        color: CrmColors.green,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  integration.name,
                  style: const TextStyle(
                    color: CrmColors.textH,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        _statusLabel,
                        style: TextStyle(
                          color: _statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConnectedSheet extends ConsumerStatefulWidget {
  final IntegrationEntity integration;
  const _ConnectedSheet({required this.integration});

  @override
  ConsumerState<_ConnectedSheet> createState() => _ConnectedSheetState();
}

class _ConnectedSheetState extends ConsumerState<_ConnectedSheet> {
  bool _isBusy = false;

  Future<void> _sync() async {
    setState(() => _isBusy = true);
    final notifier = ref.read(crmUiProvider.notifier);
    final result = await notifier.syncIntegration(widget.integration.name);
    if (!mounted) return;
    setState(() => _isBusy = false);
    _toast(result.hasError ? 'Sync failed. Check credentials.' : 'Sync completed - leads updated');
  }

  Future<void> _disconnect() async {
    setState(() => _isBusy = true);
    final notifier = ref.read(crmUiProvider.notifier);
    await notifier.disconnectIntegration(widget.integration.name);
    if (!mounted) return;
    setState(() => _isBusy = false);
    _toast('${widget.integration.name} disconnected');
  }

  void _toast(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final integration = widget.integration;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        20,
        20,
        MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: CrmColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(integration.icon, color: integration.color, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      integration.name,
                      style: const TextStyle(
                        color: CrmColors.textH,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Connected & syncing leads',
                      style: const TextStyle(color: CrmColors.textM, fontSize: 12),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: CrmColors.greenBg,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Connected',
                  style: TextStyle(
                    color: CrmColors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _infoRow(Icons.people_alt_outlined, 'Leads fetched', '${integration.leadCount}'),
          if (integration.lastSyncAt != null && integration.lastSyncAt!.isNotEmpty)
            _infoRow(Icons.sync_rounded, 'Last sync', integration.lastSyncAt!),
          _infoRow(
            Icons.circle,
            'Status',
            integration.isSyncing ? 'Syncing...' : integration.hasError ? 'Sync error' : 'Ready',
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isBusy ? null : _sync,
                  icon: _isBusy
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Sync Now'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CrmColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _isBusy ? null : _disconnect,
                  icon: const Icon(Icons.link_off_rounded, size: 16),
                  label: const Text('Disconnect'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CrmColors.red,
                    side: const BorderSide(color: CrmColors.red),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 15, color: CrmColors.textM),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(color: CrmColors.textM, fontSize: 12)),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              color: CrmColors.textH,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

