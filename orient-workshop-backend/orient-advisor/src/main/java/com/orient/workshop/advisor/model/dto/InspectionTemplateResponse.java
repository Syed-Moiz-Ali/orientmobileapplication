package com.orient.workshop.advisor.model.dto;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data @Builder @NoArgsConstructor @AllArgsConstructor
public class InspectionTemplateResponse {
    private Long id;
    private String name;
    private String description;
    private Integer estimatedMinutes;
    private List<Section> sections;

    @Data @Builder @NoArgsConstructor @AllArgsConstructor
    public static class Section {
        private Long id;
        private String sectionKey;
        private String label;
        private Integer displayOrder;
        private List<String> items;
    }
}
