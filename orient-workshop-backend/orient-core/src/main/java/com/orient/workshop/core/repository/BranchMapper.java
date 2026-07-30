package com.orient.workshop.core.repository;
import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.core.model.entity.Branch;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface BranchMapper extends BaseMapper<Branch> {}
