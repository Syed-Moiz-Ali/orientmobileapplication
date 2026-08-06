package com.orient.workshop.owner.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @JsonIgnoreProperties(ignoreUnknown = true)
public class PurchaseOrderRequest {
    private Long supplierId;
    private List<PoLine> items;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class PoLine {
        private Long inventoryItemId;
        private String itemName;
        private Integer qty;
        private BigDecimal unitCost;
    }
}
