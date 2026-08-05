package com.orient.workshop.supervisor.repository;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
import java.util.List;

@Mapper
public interface SupervisorStatsMapper {

    @Select("SELECT job_card_id FROM invoices WHERE job_card_id IS NOT NULL")
    List<Long> invoicedJobCardIds();

    @Select("SELECT COALESCE(SUM(grand_total), 0) FROM repair_orders")
    BigDecimal sumRepairGrand();

    @Select("SELECT COALESCE(SUM(services_total), 0) FROM repair_orders")
    BigDecimal sumRepairServices();

    @Select("SELECT COALESCE(SUM(parts_total), 0) FROM repair_orders")
    BigDecimal sumRepairParts();

    @Select("SELECT COUNT(*) FROM inspections WHERE is_draft = TRUE")
    long countDraftInspections();

    @Select("SELECT COUNT(*) FROM approvals WHERE action = 'pending'")
    long countPendingApprovals();

    @Select("SELECT COUNT(*) FROM work_assignments WHERE status <> 'Completed'")
    long countActiveAssignments();
}
