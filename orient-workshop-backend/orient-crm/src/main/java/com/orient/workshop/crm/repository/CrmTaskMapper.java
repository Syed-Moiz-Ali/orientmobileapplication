package com.orient.workshop.crm.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.crm.model.entity.CrmTask;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface CrmTaskMapper extends BaseMapper<CrmTask> {
}
