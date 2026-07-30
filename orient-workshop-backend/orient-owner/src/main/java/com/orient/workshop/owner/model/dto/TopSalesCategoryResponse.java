package com.orient.workshop.owner.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class TopSalesCategoryResponse {
    private String title;
    private List<TopSalesItem> items;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class TopSalesItem {
        private int sno;
        private String description;
        private String value;
    }
}
