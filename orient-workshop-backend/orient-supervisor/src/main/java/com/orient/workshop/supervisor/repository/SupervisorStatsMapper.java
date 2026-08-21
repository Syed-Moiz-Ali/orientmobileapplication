package com.orient.workshop.supervisor.repository;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
import java.util.List;

@Mapper
public interface SupervisorStatsMapper {

    @Select("SELECT job_card_id FROM invoices WHERE job_card_id IS NOT NULL")
    List<Long> invoicedJobCardIds();

    @Select("""
            SELECT i.job_card_id FROM invoices i
            JOIN job_cards jc ON jc.id = i.job_card_id
            WHERE i.job_card_id IS NOT NULL AND jc.branch_id = #{branchId}
            """)
    List<Long> invoicedJobCardIdsByBranch(@Param("branchId") Long branchId);

    @Select("SELECT COALESCE(SUM(grand_total), 0) FROM repair_orders")
    BigDecimal sumRepairGrand();

    @Select("""
            SELECT COALESCE(SUM(ro.grand_total), 0) FROM repair_orders ro
            JOIN job_cards jc ON jc.id = ro.job_card_id
            WHERE jc.branch_id = #{branchId}
            """)
    BigDecimal sumRepairGrandByBranch(@Param("branchId") Long branchId);

    @Select("SELECT COALESCE(SUM(services_total), 0) FROM repair_orders")
    BigDecimal sumRepairServices();

    @Select("""
            SELECT COALESCE(SUM(ro.services_total), 0) FROM repair_orders ro
            JOIN job_cards jc ON jc.id = ro.job_card_id
            WHERE jc.branch_id = #{branchId}
            """)
    BigDecimal sumRepairServicesByBranch(@Param("branchId") Long branchId);

    @Select("SELECT COALESCE(SUM(parts_total), 0) FROM repair_orders")
    BigDecimal sumRepairParts();

    @Select("""
            SELECT COALESCE(SUM(ro.parts_total), 0) FROM repair_orders ro
            JOIN job_cards jc ON jc.id = ro.job_card_id
            WHERE jc.branch_id = #{branchId}
            """)
    BigDecimal sumRepairPartsByBranch(@Param("branchId") Long branchId);

    @Select("SELECT COUNT(*) FROM inspections WHERE is_draft = TRUE")
    long countDraftInspections();

    @Select("""
            SELECT COUNT(*) FROM inspections i
            JOIN job_cards jc ON jc.id = i.job_card_id
            WHERE i.is_draft = TRUE AND jc.branch_id = #{branchId}
            """)
    long countDraftInspectionsByBranch(@Param("branchId") Long branchId);

    @Select("SELECT COUNT(*) FROM approvals WHERE action = 'pending'")
    long countPendingApprovals();

    @Select("""
            SELECT COUNT(*) FROM approvals a
            JOIN repair_orders ro ON ro.repair_order_ref = a.estimate_id
            JOIN job_cards jc ON jc.id = ro.job_card_id
            WHERE a.action = 'pending' AND jc.branch_id = #{branchId}
            """)
    long countPendingApprovalsByBranch(@Param("branchId") Long branchId);

    @Select("SELECT COUNT(*) FROM work_assignments WHERE status <> 'Completed'")
    long countActiveAssignments();

    @Select("SELECT COUNT(*) FROM work_assignments WHERE status <> 'Completed' AND branch_id = #{branchId}")
    long countActiveAssignmentsByBranch(@Param("branchId") Long branchId);
}
