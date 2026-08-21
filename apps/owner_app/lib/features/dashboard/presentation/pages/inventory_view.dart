import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/inventory_providers.dart';

class InventoryView extends ConsumerStatefulWidget {
  const InventoryView({super.key});

  @override
  ConsumerState<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends ConsumerState<InventoryView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final state = ref.watch(inventoryProvider);
    final notifier = ref.read(inventoryProvider.notifier);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: colorScheme.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Inventory & Spare Parts',
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w900,
            color: colorScheme.onSurface,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: colorScheme.onSurface),
            onPressed: notifier.load,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton.extended(
              backgroundColor: colorScheme.primary,
              foregroundColor: colorScheme.onPrimary,
              elevation: 4,
              onPressed: () => _showAddItemSheet(context, notifier, colorScheme, textTheme),
              icon: const Icon(Icons.add_rounded),
              label: const Text('Add Part', style: TextStyle(fontWeight: FontWeight.w800)),
            )
          : null,
      body: state.isLoading
          ? Center(child: CircularProgressIndicator(color: colorScheme.primary))
          : state.error.isNotEmpty && state.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.error, style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: notifier.load, child: const Text('Retry')),
                    ],
                  ),
                )
              : SafeArea(
                  child: Column(
                    children: [
                      if (state.lowStockItems.isNotEmpty && _tab == 0)
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF3C7),
                            borderRadius: BorderRadius.circular(AppDimensions.r16),
                            border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.5)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded, color: Color(0xFFB45309), size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${state.lowStockItems.length} item(s) at or below reorder threshold',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: const Color(0xFF92400E),
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceContainerLow,
                          borderRadius: BorderRadius.circular(AppDimensions.r14),
                        ),
                        child: Row(
                          children: [
                            _TabButton(
                              label: 'Parts & Stock',
                              isSelected: _tab == 0,
                              onTap: () => setState(() => _tab = 0),
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                            _TabButton(
                              label: 'Suppliers',
                              isSelected: _tab == 1,
                              onTap: () => setState(() => _tab = 1),
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                            _TabButton(
                              label: 'Purchase Orders',
                              isSelected: _tab == 2,
                              onTap: () => setState(() => _tab = 2),
                              colorScheme: colorScheme,
                              textTheme: textTheme,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: switch (_tab) {
                          0 => _ItemsTab(state: state, notifier: notifier, colorScheme: colorScheme, textTheme: textTheme),
                          1 => _SuppliersTab(suppliers: state.suppliers, colorScheme: colorScheme, textTheme: textTheme),
                          _ => _PurchaseOrdersTab(pos: state.purchaseOrders, notifier: notifier, colorScheme: colorScheme, textTheme: textTheme),
                        },
                      ),
                    ],
                  ),
                ),
    );
  }

  void _showAddItemSheet(BuildContext context, InventoryNotifier notifier, ColorScheme colorScheme, TextTheme textTheme) {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final reorderCtrl = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Add Inventory Part',
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: colorScheme.onSurfaceVariant),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameCtrl,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Part / Item Name',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: skuCtrl,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'SKU / Part Number',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: priceCtrl,
                      keyboardType: TextInputType.number,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Price (AED)',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: qtyCtrl,
                      keyboardType: TextInputType.number,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                      decoration: InputDecoration(
                        labelText: 'Initial Qty',
                        filled: true,
                        fillColor: colorScheme.surfaceContainerLow,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reorderCtrl,
                keyboardType: TextInputType.number,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                decoration: InputDecoration(
                  labelText: 'Low Stock Reorder Alert Level',
                  filled: true,
                  fillColor: colorScheme.surfaceContainerLow,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () async {
                    final err = await notifier.addItem({
                      'name': nameCtrl.text.trim(),
                      'sku': skuCtrl.text.trim(),
                      'sellingPrice': double.tryParse(priceCtrl.text.trim()) ?? 0,
                      'qtyOnHand': int.tryParse(qtyCtrl.text.trim()) ?? 0,
                      'reorderLevel': int.tryParse(reorderCtrl.text.trim()) ?? 5,
                    });
                    if (ctx.mounted) Navigator.pop(ctx);
                    if (err != null && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
                    }
                  },
                  child: const Text('Add to Warehouse', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _TabButton({
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(AppDimensions.r12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: colorScheme.shadow.withValues(alpha: 0.06),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: textTheme.labelSmall?.copyWith(
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}

class _ItemsTab extends StatelessWidget {
  final InventoryState state;
  final InventoryNotifier notifier;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _ItemsTab({
    required this.state,
    required this.notifier,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
          child: TextField(
            onChanged: notifier.onSearch,
            style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            decoration: InputDecoration(
              hintText: 'Search parts by name, SKU or category…',
              hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
              prefixIcon: Icon(Icons.search_rounded, size: 20, color: colorScheme.onSurfaceVariant),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        Expanded(
          child: state.filteredItems.isEmpty
              ? Center(
                  child: Text('No matching items in stock',
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
                  itemCount: state.filteredItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 10),
                  itemBuilder: (context, i) {
                    final item = state.filteredItems[i];
                    return AppCard(
                      padding: const EdgeInsets.all(14),
                      borderRadius: AppDimensions.r16,
                      color: colorScheme.surface,
                      borderColor: item.lowStock ? const Color(0xFFF59E0B) : colorScheme.outlineVariant,
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: item.lowStock
                                  ? const Color(0xFFFEF3C7)
                                  : colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.build_rounded,
                              size: 20,
                              color: item.lowStock ? const Color(0xFFB45309) : colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.name,
                                  style: textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w800,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '${item.sku} • ${item.category}',
                                  style: textTheme.bodySmall?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                    fontFamily: AppFontFamilies.mono,
                                    fontSize: 11,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    StatusPill(
                                      label: '${item.qtyOnHand} IN STOCK',
                                      bg: item.lowStock
                                          ? const Color(0xFFFEF3C7)
                                          : const Color(0xFF10B981).withValues(alpha: 0.12),
                                      fg: item.lowStock ? const Color(0xFFB45309) : const Color(0xFF10B981),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'AED ${item.sellingPrice.toStringAsFixed(2)}',
                                      style: textTheme.labelMedium?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.remove_circle_outline_rounded, size: 22, color: colorScheme.onSurfaceVariant),
                                onPressed: () => notifier.adjustStock(item.id, -1),
                              ),
                              IconButton(
                                icon: Icon(Icons.add_circle_rounded, size: 22, color: colorScheme.primary),
                                onPressed: () => notifier.adjustStock(item.id, 1),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _SuppliersTab extends StatelessWidget {
  final List<InvSupplier> suppliers;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _SuppliersTab({
    required this.suppliers,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return suppliers.isEmpty
        ? Center(child: Text('No suppliers recorded', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: suppliers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final s = suppliers[i];
              return AppCard(
                padding: const EdgeInsets.all(14),
                borderRadius: AppDimensions.r16,
                color: colorScheme.surface,
                borderColor: colorScheme.outlineVariant,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.local_shipping_outlined, color: colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            s.name,
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800, color: colorScheme.onSurface),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            s.phone.isEmpty ? 'No contact phone' : s.phone,
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}

class _PurchaseOrdersTab extends StatelessWidget {
  final List<PurchaseOrderEntity> pos;
  final InventoryNotifier notifier;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  const _PurchaseOrdersTab({
    required this.pos,
    required this.notifier,
    required this.colorScheme,
    required this.textTheme,
  });

  @override
  Widget build(BuildContext context) {
    return pos.isEmpty
        ? Center(child: Text('No purchase orders placed', style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant)))
        : ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: pos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final po = pos[i];
              return AppCard(
                padding: const EdgeInsets.all(14),
                borderRadius: AppDimensions.r16,
                color: colorScheme.surface,
                borderColor: colorScheme.outlineVariant,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.receipt_long_rounded, color: colorScheme.primary, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            po.poRef,
                            style: textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: colorScheme.onSurface,
                              fontFamily: AppFontFamilies.mono,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'AED ${po.total} • Status: ${po.status}',
                            style: textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
  }
}
