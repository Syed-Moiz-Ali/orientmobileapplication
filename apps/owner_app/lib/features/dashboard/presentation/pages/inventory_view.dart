import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_core/shared_core.dart';
import 'package:owner_app/features/dashboard/presentation/providers/inventory_providers.dart';

/// P2 (audit): inventory screen — items, low-stock, suppliers, purchase orders.
class InventoryView extends ConsumerStatefulWidget {
  const InventoryView({super.key});

  @override
  ConsumerState<InventoryView> createState() => _InventoryViewState();
}

class _InventoryViewState extends ConsumerState<InventoryView> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inventoryProvider);
    final notifier = ref.read(inventoryProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.gray700),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Inventory',
          style: TextStyle(color: AppColors.gray900, fontSize: 17, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.gray700),
            onPressed: notifier.load,
          ),
        ],
      ),
      floatingActionButton: _tab == 0
          ? FloatingActionButton(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              onPressed: () => _showAddItemDialog(context, notifier),
              child: const Icon(Icons.add_rounded),
            )
          : null,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : state.error.isNotEmpty && state.items.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(state.error, style: const TextStyle(color: AppColors.gray500)),
                      const SizedBox(height: 12),
                      ElevatedButton(onPressed: notifier.load, child: const Text('Retry')),
                    ],
                  ),
                )
              : Column(
                  children: [
                    if (state.lowStockItems.isNotEmpty && _tab == 0)
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF3E6),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${state.lowStockItems.length} item(s) at or below reorder level',
                          style: const TextStyle(
                            color: Color(0xFFB45309),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    TabBar(
                      tabs: const [
                        Tab(text: 'Items'),
                        Tab(text: 'Suppliers'),
                        Tab(text: 'Purchase Orders'),
                      ],
                      indicatorColor: AppColors.primary,
                      labelColor: AppColors.primary,
                      unselectedLabelColor: AppColors.gray500,
                      onTap: (i) => setState(() => _tab = i),
                    ),
                    Expanded(
                      child: switch (_tab) {
                        0 => _ItemsTab(state: state, notifier: notifier),
                        1 => _SuppliersTab(suppliers: state.suppliers),
                        _ => _PurchaseOrdersTab(pos: state.purchaseOrders, notifier: notifier),
                      },
                    ),
                  ],
                ),
    );
  }

  void _showAddItemDialog(BuildContext context, InventoryNotifier notifier) {
    final nameCtrl = TextEditingController();
    final skuCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final qtyCtrl = TextEditingController();
    final reorderCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Add Inventory Item',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.gray900)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: skuCtrl, decoration: const InputDecoration(labelText: 'SKU')),
              TextField(controller: priceCtrl,
                  decoration: const InputDecoration(labelText: 'Selling price (AED)'),
                  keyboardType: TextInputType.number),
              TextField(controller: qtyCtrl,
                  decoration: const InputDecoration(labelText: 'Qty on hand'),
                  keyboardType: TextInputType.number),
              TextField(controller: reorderCtrl,
                  decoration: const InputDecoration(labelText: 'Reorder level'),
                  keyboardType: TextInputType.number),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
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
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }
}

class _ItemsTab extends StatelessWidget {
  final InventoryState state;
  final InventoryNotifier notifier;
  const _ItemsTab({required this.state, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: notifier.onSearch,
            decoration: InputDecoration(
              hintText: 'Search by name or SKU',
              prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.gray400),
              filled: true,
              fillColor: AppColors.gray50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: state.filteredItems.isEmpty
              ? const Center(child: Text('No items yet', style: TextStyle(color: AppColors.gray400)))
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                  itemCount: state.filteredItems.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 8),
                  itemBuilder: (context, i) {
                    final item = state.filteredItems[i];
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: item.lowStock ? const Color(0xFFF59E0B) : AppColors.gray200,
                          width: item.lowStock ? 1.5 : 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.name,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.gray900)),
                                const SizedBox(height: 2),
                                Text('${item.sku} \u00b7 ${item.category}',
                                    style: const TextStyle(fontSize: 11, color: AppColors.gray500)),
                                const SizedBox(height: 4),
                                Text(
                                  '${item.qtyOnHand} in stock \u00b7 AED ${item.sellingPrice.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: item.lowStock ? const Color(0xFFB45309) : AppColors.gray700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, size: 20, color: AppColors.gray500),
                            onPressed: () => notifier.adjustStock(item.id, -1),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, size: 20, color: AppColors.primary),
                            onPressed: () => notifier.adjustStock(item.id, 1),
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
  const _SuppliersTab({required this.suppliers});

  @override
  Widget build(BuildContext context) {
    return suppliers.isEmpty
        ? const Center(child: Text('No suppliers yet', style: TextStyle(color: AppColors.gray400)))
        : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: suppliers.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final s = suppliers[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.name,
                        style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gray900)),
                    const SizedBox(height: 2),
                    Text(s.phone.isEmpty ? 'No phone' : s.phone,
                        style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
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
  const _PurchaseOrdersTab({required this.pos, required this.notifier});

  @override
  Widget build(BuildContext context) {
    return pos.isEmpty
        ? const Center(child: Text('No purchase orders yet', style: TextStyle(color: AppColors.gray400)))
        : ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: pos.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final po = pos[i];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.gray200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(po.poRef,
                              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.gray900)),
                          const SizedBox(height: 2),
                          Text('AED ${po.total} \u00b7 ${po.status}',
                              style: const TextStyle(fontSize: 12, color: AppColors.gray500)),
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
