package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Booking;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface BookingMapper extends BaseMapper<Booking> {

    @Select("SELECT * FROM bookings WHERE customer_id = #{customerId} ORDER BY created_at DESC")
    List<Booking> findByCustomerId(@Param("customerId") Long customerId);

    @Select("SELECT * FROM bookings WHERE customer_id = #{customerId} AND branch_id = #{branchId} ORDER BY created_at DESC")
    List<Booking> findByCustomerIdAndBranch(@Param("customerId") Long customerId, @Param("branchId") Long branchId);

    @Select("SELECT * FROM bookings WHERE advisor_id IS NULL ORDER BY created_at DESC")
    List<Booking> findUnassigned();

    @Select("SELECT * FROM bookings WHERE advisor_id IS NULL AND branch_id = #{branchId} ORDER BY created_at DESC")
    List<Booking> findUnassignedByBranch(@Param("branchId") Long branchId);

    @Select("SELECT * FROM bookings WHERE advisor_id = #{advisorId} ORDER BY created_at DESC")
    List<Booking> findByAdvisorId(@Param("advisorId") Long advisorId);

    @Select("SELECT * FROM bookings WHERE advisor_id = #{advisorId} AND job_card_id IS NULL ORDER BY booking_date ASC")
    List<Booking> findOpenByAdvisorId(@Param("advisorId") Long advisorId);
}
