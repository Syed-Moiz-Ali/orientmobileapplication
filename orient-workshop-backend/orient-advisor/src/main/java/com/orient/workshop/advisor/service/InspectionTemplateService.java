package com.orient.workshop.advisor.service;

import com.orient.workshop.advisor.model.dto.InspectionTemplateResponse;
import com.orient.workshop.advisor.repository.InspectionTemplateMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
@RequiredArgsConstructor
public class InspectionTemplateService {
    private final InspectionTemplateMapper mapper;

    public InspectionTemplateResponse getDefaultTemplate() {
        Map<String, Object> row = mapper.findDefaultTemplate();
        if (row == null || row.isEmpty()) {
            return InspectionTemplateResponse.builder()
                    .name("Offline fallback")
                    .sections(List.of())
                    .build();
        }
        Long templateId = number(row.get("id"));
        List<InspectionTemplateResponse.Section> sections = mapper.findSections(templateId).stream()
                .map(section -> {
                    Long sectionId = number(section.get("id"));
                    return InspectionTemplateResponse.Section.builder()
                            .id(sectionId)
                            .sectionKey(text(section.get("section_key")))
                            .label(text(section.get("label")))
                            .displayOrder(integer(section.get("display_order")))
                            .items(mapper.findItems(sectionId))
                            .build();
                })
                .toList();
        return InspectionTemplateResponse.builder()
                .id(templateId)
                .name(text(row.get("name")))
                .description(text(row.get("description")))
                .estimatedMinutes(integer(row.get("estimated_minutes")))
                .sections(sections)
                .build();
    }

    private static Long number(Object value) {
        return value instanceof Number n ? n.longValue() : Long.valueOf(value.toString());
    }

    private static Integer integer(Object value) {
        return value == null ? null : value instanceof Number n ? n.intValue() : Integer.valueOf(value.toString());
    }

    private static String text(Object value) {
        return value == null ? "" : value.toString();
    }
}
