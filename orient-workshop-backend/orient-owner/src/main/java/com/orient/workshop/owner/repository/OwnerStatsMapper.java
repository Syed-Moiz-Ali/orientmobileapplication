package com.orient.workshop.owner.repository;

import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Mapper
public interface OwnerStatsMapper {

    @Select("SELECT s.name AS name, SUM(s.qty * s.rate) AS value FROM repair_order_services s GROUP BY s.name ORDER BY value DESC LIMIT #{limit}")
    List<Map<String, Object>> topLabour(@Param("limit") int limit);

    @Select("SELECT p.name AS name, SUM(p.qty * p.rate) AS value FROM repair_order_parts p GROUP BY p.name ORDER BY value DESC LIMIT #{limit}")
    List<Map<String, Object>> topParts(@Param("limit") int limit);

    @Select("SELECT COALESCE(SUM(services_total), 0) FROM repair_orders")
    BigDecimal sumServicesTotal();

    @Select("SELECT COALESCE(SUM(services_total), 0) FROM repair_orders ro JOIN job_cards jc ON jc.id = ro.job_card_id WHERE jc.branch_id = #{branchId}")
    BigDecimal sumServicesTotalByBranch(@Param("branchId") Long branchId);

    @Select("SELECT COALESCE(SUM(parts_total), 0) FROM repair_orders")
    BigDecimal sumPartsTotal();

    @Select("SELECT COALESCE(SUM(parts_total), 0) FROM repair_orders ro JOIN job_cards jc ON jc.id = ro.job_card_id WHERE jc.branch_id = #{branchId}")
    BigDecimal sumPartsTotalByBranch(@Param("branchId") Long branchId);

    @Select("SELECT COALESCE(SUM(grand_total), 0) FROM repair_orders")
    BigDecimal sumGrandTotal();

    @Select("SELECT wa.department AS name, COALESCE(SUM(ro.grand_total), 0) AS value " +
            "FROM work_assignments wa LEFT JOIN repair_orders ro ON ro.job_card_id = wa.job_card_id " +
            "WHERE wa.department IS NOT NULL AND wa.department <> '' GROUP BY wa.department ORDER BY value DESC LIMIT #{limit}")
    List<Map<String, Object>> revenueByDepartment(@Param("limit") int limit);

    @Select("SELECT COALESCE(c.customer_name, CONCAT('Customer #', jc.customer_id)) AS name, " +
            "COALESCE(SUM(ro.grand_total), 0) AS value " +
            "FROM repair_orders ro JOIN job_cards jc ON jc.id = ro.job_card_id " +
            "LEFT JOIN customers c ON c.id = jc.customer_id " +
            "GROUP BY c.customer_name, jc.customer_id ORDER BY value DESC LIMIT #{limit}")
    List<Map<String, Object>> salesValueByCustomer(@Param("limit") int limit);

    @Select("SELECT COALESCE(SUM(amount), 0) FROM invoices WHERE status <> 'paid'")
    BigDecimal sumOutstandingAmount();

    @Select("SELECT COALESCE(SUM(amount), 0) FROM invoices WHERE status <> 'paid' AND branch_id = #{branchId}")
    BigDecimal sumOutstandingAmountByBranch(@Param("branchId") Long branchId);

    @Select("SELECT COALESCE(SUM(amount), 0) FROM invoices")
    BigDecimal sumInvoiceAmount();

    @Select("SELECT COALESCE(SUM(amount), 0) FROM invoices WHERE branch_id = #{branchId}")
    BigDecimal sumInvoiceAmountByBranch(@Param("branchId") Long branchId);
}
