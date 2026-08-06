package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.PurchaseOrder;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;

@Mapper
public interface PurchaseOrderMapper extends BaseMapper<PurchaseOrder> {

    @Select("SELECT * FROM purchase_orders ORDER BY created_at DESC LIMIT #{limit} OFFSET #{offset}")
    List<PurchaseOrder> findPaged(@Param("limit") int limit, @Param("offset") int offset);
}
