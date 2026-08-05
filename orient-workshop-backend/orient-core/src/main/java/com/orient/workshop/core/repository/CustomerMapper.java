package com.orient.workshop.core.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Customer;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;

import java.util.List;
import java.util.Optional;

@Mapper
public interface CustomerMapper extends BaseMapper<Customer> {

    @Select("SELECT * FROM customers WHERE user_id = #{userId} LIMIT 1")
    Optional<Customer> findByUserId(@Param("userId") Long userId);

    @Select("SELECT * FROM customers WHERE phone_number = #{phone} LIMIT 1")
    Optional<Customer> findByPhone(@Param("phone") String phone);

    @Select("SELECT * FROM customers WHERE user_id = #{userId} AND branch_id = #{branchId} LIMIT 1")
    Optional<Customer> findByUserIdAndBranch(@Param("userId") Long userId, @Param("branchId") Long branchId);

    @Select("SELECT * FROM customers WHERE customer_name LIKE CONCAT('%',#{q},'%') " +
            "OR phone_number LIKE CONCAT('%',#{q},'%') OR email LIKE CONCAT('%',#{q},'%') LIMIT 20")
    List<Customer> search(@Param("q") String q);
}
