package com.orient.workshop.owner.controller;

import com.orient.workshop.auth.filter.JwtUserPrincipal;
import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.InventoryItem;
import com.orient.workshop.core.model.entity.PurchaseOrder;
import com.orient.workshop.core.model.entity.Supplier;
import com.orient.workshop.owner.model.dto.InventoryItemRequest;
import com.orient.workshop.owner.model.dto.PurchaseOrderRequest;
import com.orient.workshop.owner.service.InventoryService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Tag(name = "Owner")
@RestController
@RequestMapping("/owner/inventory")
@RequiredArgsConstructor
public class InventoryController {

    private final InventoryService inventoryService;

    @GetMapping("/items")
    public ApiResponse<List<InventoryItem>> listItems(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int size) {
        return ApiResponse.success(inventoryService.listItems(page, size));
    }

    @GetMapping("/items/search")
    public ApiResponse<List<InventoryItem>> searchItems(@RequestParam String q) {
        return ApiResponse.success(inventoryService.searchItems(q));
    }

    @GetMapping("/items/low-stock")
    public ApiResponse<List<InventoryItem>> lowStock() {
        return ApiResponse.success(inventoryService.lowStock());
    }

    @PostMapping("/items")
    public ApiResponse<InventoryItem> createItem(@Valid @RequestBody InventoryItemRequest req,
                                                 @AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(inventoryService.createItem(req, principal));
    }

    @PutMapping("/items/{id}/stock")
    public ApiResponse<InventoryItem> adjustStock(@PathVariable Long id, @RequestParam int delta) {
        return ApiResponse.success(inventoryService.adjustStock(id, delta));
    }

    @GetMapping("/suppliers")
    public ApiResponse<List<Supplier>> listSuppliers() {
        return ApiResponse.success(inventoryService.listSuppliers());
    }

    @PostMapping("/suppliers")
    public ApiResponse<Supplier> createSupplier(@RequestBody Supplier req) {
        return ApiResponse.success(inventoryService.createSupplier(req));
    }

    @GetMapping("/purchase-orders")
    public ApiResponse<List<PurchaseOrder>> listPurchaseOrders(
            @RequestParam(defaultValue = "1") int page,
            @RequestParam(defaultValue = "50") int size) {
        return ApiResponse.success(inventoryService.listPurchaseOrders(page, size));
    }

    @PostMapping("/purchase-orders")
    public ApiResponse<PurchaseOrder> createPurchaseOrder(@RequestBody PurchaseOrderRequest req,
                                                          @AuthenticationPrincipal JwtUserPrincipal principal) {
        return ApiResponse.success(inventoryService.createPurchaseOrder(req, principal));
    }

    @PostMapping("/purchase-orders/{id}/receive")
    public ApiResponse<Map<String, String>> receivePurchaseOrder(@PathVariable Long id) {
        PurchaseOrder po = inventoryService.receivePurchaseOrder(id);
        return ApiResponse.success(Map.of("poRef", po.getPoRef(), "status", po.getStatus()));
    }
}
