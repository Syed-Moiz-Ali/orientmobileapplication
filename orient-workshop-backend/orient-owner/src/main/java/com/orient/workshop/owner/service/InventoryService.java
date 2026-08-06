package com.orient.workshop.owner.service;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.exception.BadRequestException;
import com.orient.workshop.common.exception.NotFoundException;
import com.orient.workshop.common.util.IdGenerator;
import com.orient.workshop.core.model.entity.InventoryItem;
import com.orient.workshop.core.model.entity.PurchaseOrder;
import com.orient.workshop.core.model.entity.PurchaseOrderItem;
import com.orient.workshop.core.model.entity.Supplier;
import com.orient.workshop.core.repository.InventoryItemMapper;
import com.orient.workshop.core.repository.PurchaseOrderItemMapper;
import com.orient.workshop.core.repository.PurchaseOrderMapper;
import com.orient.workshop.core.repository.SupplierMapper;
import com.orient.workshop.owner.model.dto.InventoryItemRequest;
import com.orient.workshop.owner.model.dto.PurchaseOrderRequest;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.time.LocalDateTime;
import java.util.List;

/**
 * P2 (audit): inventory module — the largest missing enterprise capability.
 * Items, suppliers, purchase orders, receiving (stock increments), and the
 * low-stock view the advisor desk uses for parts stock checks.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class InventoryService {

    private final InventoryItemMapper itemMapper;
    private final SupplierMapper supplierMapper;
    private final PurchaseOrderMapper poMapper;
    private final PurchaseOrderItemMapper poItemMapper;

    // ---------- items ----------

    public List<InventoryItem> listItems(int page, int size) {
        int limit = Math.min(Math.max(size, 1), 100);
        int offset = Math.max(page - 1, 0) * limit;
        return itemMapper.findPaged(limit, offset);
    }

    public List<InventoryItem> searchItems(String q) {
        return itemMapper.search(q);
    }

    public List<InventoryItem> lowStock() {
        return itemMapper.findLowStock();
    }

    @Transactional
    public InventoryItem createItem(InventoryItemRequest req, JwtUserPrincipal principal) {
        if (req.getSku() == null || req.getSku().isBlank() || req.getName() == null || req.getName().isBlank()) {
            throw new BadRequestException("sku and name are required");
        }
        InventoryItem item = InventoryItem.builder()
                .sku(req.getSku().trim().toUpperCase())
                .name(req.getName().trim())
                .category(req.getCategory() != null ? req.getCategory() : "")
                .branchId(req.getBranchId() != null && req.getBranchId() > 0 ? req.getBranchId()
                        : (principal != null && principal.getBranchId() != null && principal.getBranchId() > 0
                        ? principal.getBranchId() : null))
                .costPrice(req.getCostPrice() != null ? req.getCostPrice() : BigDecimal.ZERO)
                .sellingPrice(req.getSellingPrice() != null ? req.getSellingPrice() : BigDecimal.ZERO)
                .qtyOnHand(req.getQtyOnHand() != null ? req.getQtyOnHand() : 0)
                .reorderLevel(req.getReorderLevel() != null ? req.getReorderLevel() : 5)
                .supplierId(req.getSupplierId())
                .build();
        itemMapper.insert(item);
        return item;
    }

    @Transactional
    public InventoryItem adjustStock(Long id, int delta) {
        InventoryItem item = requireItem(id);
        int newQty = Math.max(0, (item.getQtyOnHand() == null ? 0 : item.getQtyOnHand()) + delta);
        item.setQtyOnHand(newQty);
        itemMapper.updateById(item);
        log.info("Inventory: adjusted {} (sku {}) by {} → {}", item.getName(), item.getSku(), delta, newQty);
        return item;
    }

    // ---------- suppliers ----------

    public List<Supplier> listSuppliers() {
        return supplierMapper.selectList(null);
    }

    @Transactional
    public Supplier createSupplier(Supplier req) {
        if (req.getName() == null || req.getName().isBlank()) {
            throw new BadRequestException("Supplier name is required");
        }
        Supplier supplier = Supplier.builder()
                .name(req.getName().trim())
                .contactName(req.getContactName() != null ? req.getContactName() : "")
                .phone(req.getPhone() != null ? req.getPhone() : "")
                .email(req.getEmail() != null ? req.getEmail() : "")
                .address(req.getAddress() != null ? req.getAddress() : "")
                .isActive(true)
                .build();
        supplierMapper.insert(supplier);
        return supplier;
    }

    // ---------- purchase orders ----------

    @Transactional
    public PurchaseOrder createPurchaseOrder(PurchaseOrderRequest req, JwtUserPrincipal principal) {
        if (req.getItems() == null || req.getItems().isEmpty()) {
            throw new BadRequestException("At least one PO item is required");
        }
        PurchaseOrder po = PurchaseOrder.builder()
                .poRef(IdGenerator.shortRef("PO"))
                .supplierId(req.getSupplierId())
                .branchId(principal != null && principal.getBranchId() != null && principal.getBranchId() > 0
                        ? principal.getBranchId() : null)
                .status("draft")
                .total(BigDecimal.ZERO)
                .orderedAt(LocalDateTime.now())
                .build();
        poMapper.insert(po);

        BigDecimal total = BigDecimal.ZERO;
        for (PurchaseOrderRequest.PoLine line : req.getItems()) {
            BigDecimal unitCost = line.getUnitCost() != null ? line.getUnitCost() : BigDecimal.ZERO;
            int qty = line.getQty() != null ? line.getQty() : 1;
            total = total.add(unitCost.multiply(BigDecimal.valueOf(qty)));
            poItemMapper.insert(PurchaseOrderItem.builder()
                    .purchaseOrderId(po.getId())
                    .inventoryItemId(line.getInventoryItemId())
                    .itemName(line.getItemName() != null ? line.getItemName() : "")
                    .qty(qty)
                    .unitCost(unitCost)
                    .build());
        }
        po.setTotal(total.setScale(2, RoundingMode.HALF_UP));
        po.setStatus("ordered");
        poMapper.updateById(po);
        return po;
    }

    @Transactional
    public PurchaseOrder receivePurchaseOrder(Long poId) {
        PurchaseOrder po = poMapper.selectById(poId);
        if (po == null) throw new NotFoundException("Purchase order not found: " + poId);
        if ("received".equals(po.getStatus())) return po;
        if (!"ordered".equals(po.getStatus())) {
            throw new BadRequestException("Only ordered purchase orders can be received (status: " + po.getStatus() + ")");
        }
        for (PurchaseOrderItem line : poItemMapper.findByPurchaseOrderId(poId)) {
            if (line.getInventoryItemId() == null) continue;
            InventoryItem item = itemMapper.selectById(line.getInventoryItemId());
            if (item == null) continue;
            item.setQtyOnHand((item.getQtyOnHand() == null ? 0 : item.getQtyOnHand()) + line.getQty());
            itemMapper.updateById(item);
        }
        po.setStatus("received");
        po.setReceivedAt(LocalDateTime.now());
        poMapper.updateById(po);
        log.info("PO {} received, stock incremented", po.getPoRef());
        return po;
    }

    public List<PurchaseOrder> listPurchaseOrders(int page, int size) {
        int limit = Math.min(Math.max(size, 1), 100);
        int offset = Math.max(page - 1, 0) * limit;
        return poMapper.findPaged(limit, offset);
    }

    private InventoryItem requireItem(Long id) {
        InventoryItem item = itemMapper.selectById(id);
        if (item == null) throw new NotFoundException("Inventory item not found: " + id);
        return item;
    }
}
