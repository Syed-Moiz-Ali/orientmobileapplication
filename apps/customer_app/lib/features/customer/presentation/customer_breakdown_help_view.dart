import 'package:customer_app/core/local/sync_providers.dart';
import 'package:customer_app/features/customer/domain/entities/customer_entities.dart';
import 'package:customer_app/features/customer/presentation/providers/customer_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:shared_core/shared_core.dart';

class CustomerBreakdownHelpView extends ConsumerStatefulWidget {
  const CustomerBreakdownHelpView({super.key});

  @override
  ConsumerState<CustomerBreakdownHelpView> createState() => _CustomerBreakdownHelpViewState();
}

class _CustomerBreakdownHelpViewState extends ConsumerState<CustomerBreakdownHelpView> {
  final _notesCtrl = TextEditingController();
  final _locationCtrl = TextEditingController(text: 'Current GPS Location (Auto-detected)');
  final _searchCtrl = TextEditingController();

  CustomerVehicleEntity? _selectedVehicle;
  String? _selectedIssue;
  String _selectedCategory = 'All';
  bool _isSaving = false;

  List<CustomerVehicleEntity> get _vehicles => ref.watch(customerDashboardProvider).vehicles;

  // Expanded dataset structure with categories to showcase future-proofing
  static const _issues = [
    (Icons.battery_alert_rounded, 'Battery Dead', 'Jumpstart or battery replacement', 'Electrical'),
    (Icons.tire_repair_rounded, 'Flat Tyre', 'Tyre change or puncture repair', 'Wheels'),
    (Icons.device_thermostat_rounded, 'Overheating', 'Coolant leak or engine heat', 'Engine'),
    (Icons.local_gas_station_rounded, 'Fuel Empty', 'Emergency fuel delivery', 'Fluid'),
    (Icons.key_rounded, 'Key Locked', 'Lockout assistance & key service', 'Access'),
    (Icons.car_crash_rounded, 'Accident / Towing', 'Priority flatbed towing unit', 'Emergency'),
    (Icons.electrical_services_rounded, 'Alternator Failure', 'Electrical charging system issue', 'Electrical'),
    (Icons.warning_rounded, 'Brake Failure', 'Hydraulic pressure loss or pads', 'Mechanical'),
  ];

  @override
  void initState() {
    super.initState();
    final vehicles = ref.read(customerDashboardProvider).vehicles;
    if (vehicles.isNotEmpty) {
      _selectedVehicle = vehicles.first;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    _locationCtrl.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_selectedIssue == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select the breakdown issue type'), behavior: SnackBarBehavior.floating),
      );
      return;
    }
    setState(() => _isSaving = true);
    final local = GenericLocalDataSource(Hive.box<dynamic>('customer_breakdowns'));
    final payload = {
      'issue': _selectedIssue ?? '',
      'vehicleId': _selectedVehicle?.id ?? '',
      'vehicleName': _selectedVehicle?.displayName ?? 'Vehicle',
      'vehiclePlate': _selectedVehicle?.plateNumber ?? '',
      'location': _locationCtrl.text,
      'notes': _notesCtrl.text.trim(),
    };
    var refId = '';
    var synced = true;
    final remote = ref.read(customerRemoteDataSourceProvider);

    try {
      final resp = await remote.createBreakdown(payload);
      refId = resp.id;
    } catch (e, st) {
      ref.read(loggerProvider).e('Breakdown API failed - queueing offline', error: e, stackTrace: st);
      synced = false;
    }

    final id = refId.isNotEmpty ? refId : await IdGenerator.nextId('BD');
    await local.save(id, {...payload, 'id': id, 'status': 'pending', 'createdAt': DateTime.now().toIso8601String()});

    if (!synced) {
      final queue = ref.read(syncQueueProvider);
      await queue.enqueue(
        SyncOperation(
          id: id,
          entityType: 'breakdown',
          entityId: id,
          changeType: ChangeType.create,
          payload: payload,
          timestamp: DateTime.now().millisecondsSinceEpoch,
        ),
      );
      await ref.read(syncEngineProvider).syncAll();
    }

    ref.invalidate(customerBreakdownsProvider);
    if (!mounted) return;
    Navigator.pop(context);
  }

  void _callHelpline() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Calling Emergency Helpline: 800-ORIENT (800-674368)'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    // Filter logic for scalability (Category + Search Query)
    const categories = ['All', 'Electrical', 'Wheels', 'Engine', 'Mechanical', 'Emergency'];

    final filteredIssues = _issues.where((item) {
      final matchesCategory = _selectedCategory == 'All' || item.$4 == _selectedCategory;
      final query = _searchCtrl.text.toLowerCase();
      final matchesSearch =
          query.isEmpty || item.$2.toLowerCase().contains(query) || item.$3.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      // ── BOTTOM DOCKED CHECKOUT BAR ─────────────────────────────────────────
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(24).copyWith(bottom: MediaQuery.of(context).padding.bottom + 24),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
          boxShadow: [
            BoxShadow(color: colorScheme.shadow.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -8)),
          ],
        ),
        child: Row(
          children: [
            SizedBox(
              height: 56,
              child: OutlinedButton(
                onPressed: _callHelpline,
                style: OutlinedButton.styleFrom(
                  foregroundColor: colorScheme.error,
                  side: BorderSide(color: colorScheme.error.withValues(alpha: 0.5)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: Row(
                  children: [
                    Icon(Icons.phone_rounded, size: 18, color: colorScheme.error),
                    const SizedBox(width: 8),
                    const Text('Call', style: TextStyle(fontWeight: FontWeight.w800)),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 56,
                child: FilledButton.icon(
                  onPressed: _isSaving ? null : _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: colorScheme.error,
                    foregroundColor: colorScheme.onError,
                    disabledBackgroundColor: colorScheme.surfaceContainerHighest,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
                  ),
                  icon: _isSaving
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: colorScheme.onError),
                        )
                      : const Icon(Icons.warning_amber_rounded, size: 22),
                  label: Text(
                    _isSaving ? 'Dispatching Unit...' : 'Request Emergency Dispatch',
                    style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w900, color: colorScheme.onError),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            AppTopBar(
              title: '24/7 Roadside SOS',
              trailing: IconButton(
                onPressed: _callHelpline,
                icon: Icon(Icons.phone_in_talk_rounded, color: colorScheme.error),
                tooltip: 'Call Emergency Helpline',
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: AppResponsivePage(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── EMERGENCY HERO BANNER ────────────────────────────────
                    AppCard(
                      borderRadius: 24,
                      elevation: 0,
                      color: colorScheme.errorContainer.withValues(alpha: 0.6),
                      borderColor: colorScheme.error.withValues(alpha: 0.3),
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(color: colorScheme.error, shape: BoxShape.circle),
                            child: Icon(Icons.sos_rounded, color: colorScheme.onError, size: 28),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Emergency Assistance',
                                  style: textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: colorScheme.error,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Avg response: 15–20 mins • Free towing up to 40km',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── ISSUE SELECTION SECTION (SCALABLE & CHIP GRID) ───────
                    Text(
                      'Select Issue Type',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Filter categories or search symptoms below',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),

                    // 1. Search Bar for Future-Proof Scaling
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (_) => setState(() {}),
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        hintText: 'Search specific issue (e.g. battery, tyre)...',
                        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                        prefixIcon: Icon(Icons.search_rounded, color: colorScheme.onSurfaceVariant),
                        filled: true,
                        fillColor: colorScheme.surface,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.outlineVariant),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: colorScheme.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 2. Category Filter Chips (Horizontal Scroll)
                    SizedBox(
                      height: 40,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, index) {
                          final cat = categories[index];
                          final isSelected = _selectedCategory == cat;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              decoration: BoxDecoration(
                                color: isSelected ? colorScheme.primary : colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                                ),
                              ),
                              child: Center(
                                child: Text(
                                  cat,
                                  style: textTheme.labelSmall?.copyWith(
                                    color: isSelected ? colorScheme.onPrimary : colorScheme.onSurface,
                                    fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 3. Responsive Grid of Option Chips
                    if (filteredIssues.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'No matching breakdown issues found.',
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ),
                      )
                    else
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2, // 2 items per row chip grid
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1.5, // Compact rectangular chip cards
                        ),
                        itemCount: filteredIssues.length,
                        itemBuilder: (context, index) {
                          final item = filteredIssues[index];
                          return _IssueChipCard(
                            icon: item.$1,
                            title: item.$2,
                            subtitle: item.$3,
                            selected: _selectedIssue == item.$2,
                            onTap: () => setState(() => _selectedIssue = item.$2),
                            colorScheme: colorScheme,
                          );
                        },
                      ),
                    const SizedBox(height: 36),

                    // ── DISPATCH DETAILS CARD ────────────────────────────────
                    Text(
                      'Dispatch Details',
                      style: textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Confirm vehicle and breakdown location',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                    ),
                    const SizedBox(height: 16),
                    AppCard(
                      borderRadius: 24,
                      elevation: 0,
                      padding: const EdgeInsets.all(20),
                      color: colorScheme.surface,
                      borderColor: colorScheme.outlineVariant,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withValues(alpha: 0.04),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vehicle Needing Assistance',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<CustomerVehicleEntity>(
                                value: _selectedVehicle,
                                isExpanded: true,
                                dropdownColor: colorScheme.surface,
                                hint: Text(
                                  'Choose vehicle from garage',
                                  style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                ),
                                icon: Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 22,
                                ),
                                items: _vehicles
                                    .map(
                                      (v) => DropdownMenuItem(
                                        value: v,
                                        child: Text(
                                          '${v.displayName} • ${v.plateNumber.toUpperCase()}',
                                          style: textTheme.bodyMedium?.copyWith(
                                            color: colorScheme.onSurface,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) => setState(() => _selectedVehicle = v),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Current GPS Location',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            decoration: BoxDecoration(
                              color: colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: colorScheme.outlineVariant),
                            ),
                            child: Row(
                              children: [
                                const SizedBox(width: 16),
                                Icon(Icons.my_location_rounded, size: 20, color: colorScheme.error),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _locationCtrl,
                                    style: textTheme.bodyMedium?.copyWith(
                                      color: colorScheme.onSurface,
                                      fontWeight: FontWeight.w800,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter location or landmark',
                                      border: InputBorder.none,
                                      hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'Additional Notes (Optional)',
                            style: textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _notesCtrl,
                            maxLines: 2,
                            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                            decoration: InputDecoration(
                              hintText: 'e.g. Parked in basement, hard to locate',
                              hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                              filled: true,
                              fillColor: colorScheme.surfaceContainerHighest,
                              contentPadding: const EdgeInsets.all(16),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.outlineVariant),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.outlineVariant),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide(color: colorScheme.primary, width: 2),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── COMPACT ISSUE CHIP CARD GRID WIDGET ──────────────────────────────────────
class _IssueChipCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;

  const _IssueChipCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Material(
      color: selected ? colorScheme.errorContainer : colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? colorScheme.error : colorScheme.outlineVariant,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: selected ? colorScheme.error.withValues(alpha: 0.15) : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, size: 18, color: selected ? colorScheme.error : colorScheme.onSurfaceVariant),
                  ),
                  if (selected) Icon(Icons.check_circle_rounded, color: colorScheme.error, size: 18),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleSmall?.copyWith(
                      color: selected ? colorScheme.error : colorScheme.onSurface,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
