package com.orient.workshop.owner.repository;

import com.baomidou.mybatisplus.core.mapper.BaseMapper;
import com.orient.workshop.owner.model.entity.EmployeeDocument;
import org.apache.ibatis.annotations.Mapper;

@Mapper
public interface EmployeeDocumentMapper extends BaseMapper<EmployeeDocument> {
}
