package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.InventoryItem;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Optional;

@Mapper
public interface InventoryItemMapper extends BaseMapper<InventoryItem> {

    @Select("SELECT * FROM inventory_items WHERE name LIKE CONCAT('%',#{q},'%') OR sku LIKE CONCAT('%',#{q},'%') LIMIT 20")
    List<InventoryItem> search(@Param("q") String q);

    @Select("SELECT * FROM inventory_items WHERE qty_on_hand <= reorder_level ORDER BY qty_on_hand ASC")
    List<InventoryItem> findLowStock();

    @Select("SELECT * FROM inventory_items ORDER BY name ASC LIMIT #{limit} OFFSET #{offset}")
    List<InventoryItem> findPaged(@Param("limit") int limit, @Param("offset") int offset);

    @Select("SELECT COUNT(*) FROM inventory_items")
    long countAll();

    @Select("SELECT * FROM inventory_items WHERE sku = #{sku} "
            + "AND ((branch_id = #{branchId}) OR (branch_id IS NULL AND #{branchId} IS NULL)) LIMIT 1")
    Optional<InventoryItem> findBySkuAndBranch(@Param("sku") String sku, @Param("branchId") Long branchId);
}
