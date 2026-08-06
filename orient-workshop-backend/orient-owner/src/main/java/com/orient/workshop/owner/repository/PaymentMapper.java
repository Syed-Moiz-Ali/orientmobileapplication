package com.orient.workshop.owner.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.owner.model.entity.Payment;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.math.BigDecimal;
import java.util.List;

@Mapper
public interface PaymentMapper extends BaseMapper<Payment> {

    @Select("SELECT * FROM payments WHERE invoice_id = #{invoiceId} ORDER BY paid_at ASC")
    List<Payment> findByInvoiceId(@Param("invoiceId") Long invoiceId);

    @Select("SELECT COALESCE(SUM(amount), 0) FROM payments WHERE invoice_id = #{invoiceId}")
    BigDecimal sumPaidByInvoice(@Param("invoiceId") Long invoiceId);
}
