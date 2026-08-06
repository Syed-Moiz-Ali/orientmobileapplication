import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_auth/shared_auth.dart';
import 'package:shared_core/shared_core.dart';

/// P2 (audit): inventory module — items, suppliers, purchase orders.
/// Simple typed models parsed from the ApiResponse envelope.

class InvItem {
  final String id, sku, name, category;
  final double costPrice, sellingPrice;
  final int qtyOnHand, reorderLevel;
  const InvItem({
    required this.id, required this.sku, required this.name,
    required this.category, required this.costPrice, required this.sellingPrice,
    required this.qtyOnHand, required this.reorderLevel,
  });

  factory InvItem.fromJson(Map<String, dynamic> j) => InvItem(
        id: '${j['id']}',
        sku: j['sku'] as String? ?? '',
        name: j['name'] as String? ?? '',
        category: j['category'] as String? ?? '',
        costPrice: (j['costPrice'] as num?)?.toDouble() ?? 0,
        sellingPrice: (j['sellingPrice'] as num?)?.toDouble() ?? 0,
        qtyOnHand: j['qtyOnHand'] as int? ?? 0,
        reorderLevel: j['reorderLevel'] as int? ?? 0,
      );

  bool get lowStock => qtyOnHand <= reorderLevel;
}

class InvSupplier {
  final String id, name, phone;
  const InvSupplier({required this.id, required this.name, required this.phone});

  factory InvSupplier.fromJson(Map<String, dynamic> j) => InvSupplier(
        id: '${j['id']}',
        name: j['name'] as String? ?? '',
        phone: j['phone'] as String? ?? '',
      );
}

class PurchaseOrderEntity {
  final String poRef, status, total;
  const PurchaseOrderEntity({
    required this.poRef, required this.status, required this.total,
  });

  factory PurchaseOrderEntity.fromJson(Map<String, dynamic> j) => PurchaseOrderEntity(
        poRef: j['poRef'] as String? ?? '',
        status: j['status'] as String? ?? '',
        total: (j['total'] as num?)?.toString() ?? '0',
      );
}

class InventoryState {
  final bool isLoading;
  final String error;
  final List<InvItem> items;
  final List<InvSupplier> suppliers;
  final List<PurchaseOrderEntity> purchaseOrders;
  final String searchQuery;

  const InventoryState({
    this.isLoading = true,
    this.error = '',
    this.items = const [],
    this.suppliers = const [],
    this.purchaseOrders = const [],
    this.searchQuery = '',
  });

  InventoryState copyWith({
    bool? isLoading,
    String? error,
    List<InvItem>? items,
    List<InvSupplier>? suppliers,
    List<PurchaseOrderEntity>? purchaseOrders,
    String? searchQuery,
  }) => InventoryState(
        isLoading: isLoading ?? this.isLoading,
        error: error ?? this.error,
        items: items ?? this.items,
        suppliers: suppliers ?? this.suppliers,
        purchaseOrders: purchaseOrders ?? this.purchaseOrders,
        searchQuery: searchQuery ?? this.searchQuery,
      );

  List<InvItem> get filteredItems {
    if (searchQuery.isEmpty) return items;
    final q = searchQuery.toLowerCase();
    return items.where((i) =>
        i.name.toLowerCase().contains(q) || i.sku.toLowerCase().contains(q)).toList();
  }

  List<InvItem> get lowStockItems => items.where((i) => i.lowStock).toList();
}

class InventoryNotifier extends Notifier<InventoryState> {
  ApiClient get _client => ref.read(apiClientProvider);

  @override
  InventoryState build() {
    load();
    return const InventoryState();
  }

  Future<void> load() async {
    try {
      final items = (await _client.get<List<dynamic>>(
        ApiEndpoints.ownerInventoryItems,
        fromJson: (d) => d as List<dynamic>,
      )).when(success: (d) => d, failure: (e) => throw e);
      final suppliers = (await _client.get<List<dynamic>>(
        ApiEndpoints.ownerInventorySuppliers,
        fromJson: (d) => d as List<dynamic>,
      )).when(success: (d) => d, failure: (e) => throw e);
      final pos = (await _client.get<List<dynamic>>(
        ApiEndpoints.ownerInventoryPurchaseOrders,
        fromJson: (d) => d as List<dynamic>,
      )).when(success: (d) => d, failure: (e) => throw e);
      state = state.copyWith(
        isLoading: false,
        error: '',
        items: items
            .map((e) => InvItem.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        suppliers: suppliers
            .map((e) => InvSupplier.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        purchaseOrders: pos
            .map((e) => PurchaseOrderEntity.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
      );
    } catch (e, st) {
      ref.read(loggerProvider).e('Failed to load inventory', error: e, stackTrace: st);
      state = state.copyWith(isLoading: false, error: 'Could not load inventory');
    }
  }

  Future<String?> addItem(Map<String, dynamic> payload) async {
    try {
      await _client.post(ApiEndpoints.ownerInventoryItems, data: payload);
      await load();
      return null;
    } catch (e, st) {
      ref.read(loggerProvider).e('Failed to add item', error: e, stackTrace: st);
      return 'Could not add item';
    }
  }

  Future<String?> adjustStock(String id, int delta) async {
    try {
      await _client.put('${ApiEndpoints.ownerInventoryItems}/$id/stock?delta=$delta');
      await load();
      return null;
    } catch (e, st) {
      ref.read(loggerProvider).e('Failed to adjust stock', error: e, stackTrace: st);
      return 'Could not adjust stock';
    }
  }

  void onSearch(String query) => state = state.copyWith(searchQuery: query);
}

final inventoryProvider =
    NotifierProvider<InventoryNotifier, InventoryState>(InventoryNotifier.new);
