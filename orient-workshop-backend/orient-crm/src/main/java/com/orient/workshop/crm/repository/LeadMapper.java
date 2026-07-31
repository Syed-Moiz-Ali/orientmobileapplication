package com.orient.workshop.crm.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.crm.model.entity.Lead;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Map;

@Mapper
public interface LeadMapper extends BaseMapper<Lead> {

    @Select("SELECT * FROM leads WHERE external_id = #{externalId} LIMIT 1")
    Lead findByExternalId(@Param("externalId") String externalId);

    @Select("SELECT * FROM leads WHERE status = #{status} AND source = #{source} ORDER BY id DESC LIMIT #{offset}, #{size}")
    List<Lead> findByFilters(@Param("status") String status, @Param("source") String source,
                             @Param("offset") int offset, @Param("size") int size);

    @Select("SELECT * FROM leads ORDER BY id DESC LIMIT #{offset}, #{size}")
    List<Lead> findPage(@Param("offset") int offset, @Param("size") int size);

    @Select("SELECT COUNT(*) FROM leads")
    long countAll();

    @Select("SELECT COUNT(*) FROM leads WHERE status = #{status}")
    long countByStatus(@Param("status") String status);

    @Select("SELECT source AS name, COUNT(*) AS cnt FROM leads GROUP BY source ORDER BY cnt DESC")
    List<Map<String, Object>> groupBySource();

    @Select("SELECT DATE_FORMAT(created_at, '%b') AS month, status, COUNT(*) AS cnt FROM leads " +
            "WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 MONTH) GROUP BY month, status ORDER BY MIN(created_at)")
    List<Map<String, Object>> groupByMonthStatus();

    @Select("SELECT assigned_to AS name, COUNT(*) AS cnt FROM leads WHERE assigned_to IS NOT NULL AND assigned_to <> '' GROUP BY assigned_to ORDER BY cnt DESC")
    List<Map<String, Object>> groupByAssignee();

    @Select("SELECT assigned_to AS name, COUNT(*) AS cnt FROM leads WHERE assigned_to IS NOT NULL AND assigned_to <> '' AND status = 'WON' GROUP BY assigned_to")
    List<Map<String, Object>> groupByAssigneeWon();

    @Select("SELECT DATE_FORMAT(created_at, '%Y-%m') AS ym, DATE_FORMAT(created_at, '%b') AS month, status, COUNT(*) AS cnt FROM leads " +
            "WHERE created_at >= DATE_SUB(NOW(), INTERVAL 7 MONTH) GROUP BY ym, month, status ORDER BY ym")
    List<Map<String, Object>> groupByMonthStatusNamed();

    @Select("SELECT status, COUNT(*) AS cnt, COALESCE(SUM(lead_value), 0) AS total_value FROM leads GROUP BY status")
    List<Map<String, Object>> groupByStatusWithValue();

    @Select("SELECT * FROM leads WHERE follow_up_date IS NOT NULL AND follow_up_date <> '' ORDER BY follow_up_date ASC LIMIT 20")
    List<Lead> findFollowUps();

    @Select("SELECT * FROM leads WHERE follow_up_date IS NOT NULL AND follow_up_date <> '' " +
            "AND follow_up_date <= #{date} ORDER BY follow_up_date ASC LIMIT 20")
    List<Lead> findFollowUpsDue(@Param("date") String date);

    @Select("SELECT COUNT(*) FROM leads WHERE status = 'WON'")
    long countWon();

    @Select("SELECT COALESCE(SUM(lead_value), 0) FROM leads WHERE status = 'WON'")
    java.math.BigDecimal sumWonValue();

    @Select("SELECT COALESCE(SUM(lead_value), 0) FROM leads")
    java.math.BigDecimal sumTotalValue();
}
