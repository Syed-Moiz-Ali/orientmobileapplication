package com.orient.workshop.owner.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.owner.model.entity.Invoice;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface InvoiceMapper extends BaseMapper<Invoice> {

    @Select("SELECT * FROM invoices WHERE job_card_id = #{jobCardId}")
    List<Invoice> findByJobCardId(@Param("jobCardId") Long jobCardId);

    @Select("SELECT * FROM invoices WHERE customer_id = #{customerId} ORDER BY issued_date DESC")
    List<Invoice> findByCustomerId(@Param("customerId") Long customerId);
}
