package com.orient.workshop.advisor.repository;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface InspectionTemplateMapper {
    @Select("""
            SELECT id, name, description, estimated_minutes
            FROM inspection_templates
            WHERE active = TRUE
            ORDER BY is_default DESC, display_order ASC, id ASC
            LIMIT 1
            """)
    Map<String, Object> findDefaultTemplate();

    @Select("""
            SELECT id, section_key, label, display_order
            FROM inspection_template_sections
            WHERE template_id = #{templateId}
            ORDER BY display_order ASC, id ASC
            """)
    List<Map<String, Object>> findSections(Long templateId);

    @Select("""
            SELECT label
            FROM inspection_template_items
            WHERE section_id = #{sectionId} AND active = TRUE
            ORDER BY display_order ASC, id ASC
            """)
    List<String> findItems(Long sectionId);
}
