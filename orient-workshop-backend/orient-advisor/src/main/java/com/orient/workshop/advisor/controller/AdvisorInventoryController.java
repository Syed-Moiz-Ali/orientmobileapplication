package com.orient.workshop.advisor.controller;

import com.orient.workshop.common.response.ApiResponse;
import com.orient.workshop.core.model.entity.InventoryItem;
import com.orient.workshop.core.repository.InventoryItemMapper;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Tag(name = "Advisor")
@RestController
@RequestMapping("/advisor/inventory")
@RequiredArgsConstructor
public class AdvisorInventoryController {

    private final InventoryItemMapper inventoryItemMapper;

    /**
     * P2 (audit): parts stock check at the advisor desk — previously absent,
     * advisors could not see whether a part was in stock before quoting.
     */
    @GetMapping("/search")
    public ApiResponse<List<InventoryItem>> search(@RequestParam String q) {
        return ApiResponse.success(inventoryItemMapper.search(q));
    }

    @GetMapping("/low-stock")
    public ApiResponse<List<InventoryItem>> lowStock() {
        return ApiResponse.success(inventoryItemMapper.findLowStock());
    }
}
