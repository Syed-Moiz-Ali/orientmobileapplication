package com.orient.workshop.customer.repository;

import com.orient.workshop.customer.model.dto.BookingApprovalInfo;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

@Mapper
public interface CustomerApprovalLookupMapper {

    @Select("""
            SELECT a.estimate_id AS estimateId, a.amount
            FROM approvals a
            JOIN repair_orders ro ON ro.repair_order_ref = a.estimate_id
            WHERE a.customer_id = #{customerId}
              AND ro.job_card_id = #{jobCardId}
              AND a.action = 'pending'
            ORDER BY a.created_at DESC
            LIMIT 1
            """)
    BookingApprovalInfo findPendingByCustomerAndJobCard(@Param("customerId") Long customerId,
                                                        @Param("jobCardId") Long jobCardId);
}
