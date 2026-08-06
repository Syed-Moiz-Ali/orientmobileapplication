package com.orient.workshop.owner.model.dto;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data @Builder @NoArgsConstructor @AllArgsConstructor @JsonIgnoreProperties(ignoreUnknown = true)
public class InventoryItemRequest {
    private String sku;
    private String name;
    private String category;
    private Long branchId;
    private BigDecimal costPrice;
    private BigDecimal sellingPrice;
    private Integer qtyOnHand;
    private Integer reorderLevel;
    private Long supplierId;
}
